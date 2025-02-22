# frozen_string_literal: true

require 'base64'
require 'saml/errors'
require 'saml/post_url_service'
require 'saml/responses/login'
require 'saml/responses/logout'
require 'saml/ssoe_settings_service'
require 'login/after_login_actions'

module V1
  class SessionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    REDIRECT_URLS = %w[signup mhv dslogon idme idme_signup logingov logingov_signup custom mfa verify slo].freeze
    STATSD_SSO_NEW_KEY = 'api.auth.new'
    STATSD_SSO_SAMLREQUEST_KEY = 'api.auth.saml_request'
    STATSD_SSO_SAMLRESPONSE_KEY = 'api.auth.saml_response'
    STATSD_SSO_SAMLTRACKER_KEY = 'api.auth.saml_tracker'
    STATSD_SSO_CALLBACK_KEY = 'api.auth.saml_callback'
    STATSD_SSO_CALLBACK_TOTAL_KEY = 'api.auth.login_callback.total'
    STATSD_SSO_CALLBACK_FAILED_KEY = 'api.auth.login_callback.failed'
    STATSD_LOGIN_NEW_USER_KEY = 'api.auth.new_user'
    STATSD_LOGIN_STATUS_SUCCESS = 'api.auth.login.success'
    STATSD_LOGIN_STATUS_FAILURE = 'api.auth.login.failure'
    STATSD_LOGIN_LATENCY = 'api.auth.latency'
    VERSION_TAG = 'version:v1'
    FIM_INVALID_MESSAGE_TIMESTAMP = 'invalid_message_timestamp'

    # Collection Action: auth is required for certain types of requests
    # @type is set automatically by the routes in config/routes.rb
    # For more details see SAML::SSOeSettingsService and SAML::URLService
    def new
      type = params[:type]

      if type == 'slo'
        Rails.logger.info("SessionsController version:v1 LOGOUT of type #{type}", sso_logging_info)
        reset_session
        url = url_service.ssoe_slo_url
        # due to shared url service implementation
        # clientId must be added at the end or the URL will be invalid for users using various "Do not track"
        # extensions with their browser.
        redirect_to params[:client_id].present? ? url + "&clientId=#{params[:client_id]}" : url
      else
        render_login(type)
      end
      new_stats(type)
    end

    def ssoe_slo_callback
      Rails.logger.info("SessionsController version:v1 ssoe_slo_callback, user_uuid=#{@current_user&.uuid}")
      redirect_to url_service.logout_redirect_url
    end

    def saml_callback
      set_sentry_context_for_callback if html_escaped_relay_state['type'] == 'mfa'
      saml_response = SAML::Responses::Login.new(params[:SAMLResponse], settings: saml_settings)
      saml_response_stats(saml_response)
      raise_saml_error(saml_response) unless saml_response.valid?
      user_login(saml_response)
      callback_stats(:success, saml_response)
      Rails.logger.info("SessionsController version:v1 saml_callback complete, user_uuid=#{@current_user&.uuid}")
    rescue SAML::SAMLError => e
      handle_callback_error(e, :failure, saml_response, e.level, e.context, e.code, e.tag)
    rescue => e
      # the saml_response variable may or may not be defined depending on
      # where the exception was raised
      resp = defined?(saml_response) && saml_response
      handle_callback_error(e, :failed_unknown, resp)
    ensure
      callback_stats(:total)
    end

    def tracker
      id = params[:id]
      type = params[:type]
      authn = params[:authn]
      values = { 'id' => id, 'type' => type, 'authn' => authn }
      if REDIRECT_URLS.include?(type) && SAML::User::AUTHN_CONTEXTS.keys.include?(authn)
        Rails.logger.info("SSOe: SAML Tracker => #{values}")
        StatsD.increment(STATSD_SSO_SAMLTRACKER_KEY,
                         tags: ["type:#{type}", "context:#{authn}", VERSION_TAG])
      end
    end

    def metadata
      meta = OneLogin::RubySaml::Metadata.new
      render xml: meta.generate(saml_settings), content_type: 'application/xml'
    end

    private

    def set_sentry_context_for_callback
      temp_session_object = Session.find(session[:token])
      temp_current_user = User.find(temp_session_object.uuid) if temp_session_object&.uuid
      Raven.extra_context(
        current_user_uuid: temp_current_user.try(:uuid),
        current_user_icn: temp_current_user.try(:mhv_icn)
      )
    end

    def saml_settings(options = {})
      # add a forceAuthn value to the saml settings based on the initial options or
      # default to false
      options[:force_authn] ||= false
      SAML::SSOeSettingsService.saml_settings(options)
    end

    def raise_saml_error(form)
      code = form.error_code
      if code == SAML::Responses::Base::AUTH_TOO_LATE_ERROR_CODE && validate_session
        code = UserSessionForm::ERRORS[:saml_replay_valid_session][:code]
      end
      raise SAML::FormError.new(form, code)
    end

    def authenticate
      return unless action_name == 'new'

      if %w[mfa verify].include?(params[:type])
        super
      elsif params[:type] == 'slo'
        # load the session object and current user before attempting to destroy
        load_user
        reset_session
      else
        reset_session
      end
    end

    def user_login(saml_response)
      user_session_form = UserSessionForm.new(saml_response)
      raise_saml_error(user_session_form) unless user_session_form.valid?

      @current_user, @session_object = user_session_form.persist
      set_cookies
      after_login_actions
      if url_service.should_uplevel?
        render_login('verify')
      else
        redirect_to url_service.login_redirect_url
        login_stats(:success)
      end
    end

    def render_login(type)
      login_url, post_params = login_params(type)
      tracker = url_service.tracker
      renderer = ActionController::Base.renderer
      renderer.controller.prepend_view_path(Rails.root.join('lib', 'saml', 'templates'))
      result = renderer.render template: 'sso_post_form',
                               locals: {
                                 url: login_url,
                                 params: post_params,
                                 id: tracker.uuid,
                                 authn: tracker.payload_attr(:authn_context),
                                 type: tracker.payload_attr(:type),
                                 sentrydsn: Settings.sentry.dsn
                               },
                               format: :html
      render body: result, content_type: 'text/html'
      set_sso_saml_cookie!
      saml_request_stats
    end

    def set_sso_saml_cookie!
      cookies[Settings.ssoe_eauth_cookie.name] = {
        value: saml_cookie_content.to_json,
        expires: nil,
        secure: Settings.ssoe_eauth_cookie.secure,
        httponly: true,
        domain: Settings.ssoe_eauth_cookie.domain
      }
    end

    def saml_cookie_content
      {
        'timestamp' => Time.now.iso8601,
        'transaction_id' => url_service.tracker&.payload_attr(:transaction_id),
        'saml_request_id' => url_service.tracker&.uuid,
        'saml_request_query_params' => url_service.query_params
      }
    end

    # rubocop:disable Metrics/MethodLength
    def login_params(type)
      raise Common::Exceptions::RoutingError, type unless REDIRECT_URLS.include?(type)

      case type
      when 'signup'
        url_service.signup_url
      when 'mhv'
        url_service.mhv_url
      when 'dslogon'
        url_service.dslogon_url
      when 'idme'
        url_service.idme_url
      when 'idme_signup'
        url_service.idme_signup_url
      when 'logingov'
        url_service.logingov_url
      when 'logingov_signup'
        url_service.logingov_signup_url
      when 'mfa'
        url_service.mfa_url
      when 'verify'
        url_service.verify_url
      when 'custom'
        raise Common::Exceptions::ParameterMissing, 'authn' if params[:authn].blank?

        url_service(false).custom_url params[:authn]
      end
    end
    # rubocop:enable Metrics/MethodLength

    def saml_request_stats
      tracker = url_service.tracker
      values = {
        'id' => tracker&.uuid,
        'authn' => tracker&.payload_attr(:authn_context),
        'type' => tracker&.payload_attr(:type),
        'transaction_id' => tracker&.payload_attr(:transaction_id)
      }
      Rails.logger.info("SSOe: SAML Request => #{values}")
      StatsD.increment(STATSD_SSO_SAMLREQUEST_KEY,
                       tags: ["type:#{tracker&.payload_attr(:type)}",
                              "context:#{tracker&.payload_attr(:authn_context)}",
                              VERSION_TAG])
    end

    def saml_response_stats(saml_response)
      uuid = saml_response.in_response_to
      tracker = SAMLRequestTracker.find(uuid)
      values = {
        'id' => uuid,
        'authn' => saml_response.authn_context,
        'type' => tracker&.payload_attr(:type),
        'transaction_id' => tracker&.payload_attr(:transaction_id)
      }
      Rails.logger.info("SSOe: SAML Response => #{values}")
      StatsD.increment(STATSD_SSO_SAMLRESPONSE_KEY,
                       tags: ["type:#{tracker&.payload_attr(:type)}",
                              "context:#{saml_response.authn_context}",
                              VERSION_TAG])
    end

    def user_logout(saml_response)
      logout_request = SingleLogoutRequest.find(saml_response&.in_response_to)
      if logout_request.present?
        logout_request.destroy
        Rails.logger.info("SLO callback response to '#{saml_response&.in_response_to}' for originating_request_id "\
                          "'#{originating_request_id}'")
      else
        Rails.logger.info('SLO callback response could not resolve logout request for originating_request_id '\
                          "'#{originating_request_id}'")
      end
    end

    def new_stats(type)
      tags = ["context:#{type}", VERSION_TAG]
      StatsD.increment(STATSD_SSO_NEW_KEY, tags: tags)
      Rails.logger.info("SSO_NEW_KEY, tags: #{tags}")
    end

    def login_stats(status, error = nil)
      type = url_service.tracker.payload_attr(:type)
      tags = ["context:#{type}", VERSION_TAG]
      case status
      when :success
        StatsD.increment(STATSD_LOGIN_NEW_USER_KEY, tags: [VERSION_TAG]) if type == 'signup'
        StatsD.increment(STATSD_LOGIN_STATUS_SUCCESS, tags: tags)
        Rails.logger.info("LOGIN_STATUS_SUCCESS, tags: #{tags}")
        Rails.logger.info("SessionsController version:v1 login complete, user_uuid=#{@current_user&.uuid}")
        StatsD.measure(STATSD_LOGIN_LATENCY, url_service.tracker.age, tags: tags)
      when :failure
        tags_and_error_code = tags << "error:#{error.try(:code) || SAML::Responses::Base::UNKNOWN_OR_BLANK_ERROR_CODE}"
        error_message = error.try(:message) || 'Unknown'
        StatsD.increment(STATSD_LOGIN_STATUS_FAILURE, tags: tags_and_error_code)
        Rails.logger.info("LOGIN_STATUS_FAILURE, tags: #{tags_and_error_code}, message: #{error_message}")
        Rails.logger.info("SessionsController version:v1 login failure, user_uuid=#{@current_user&.uuid}")
      end
    end

    def callback_stats(status, saml_response = nil, failure_tag = nil)
      case status
      when :success
        StatsD.increment(STATSD_SSO_CALLBACK_KEY,
                         tags: ['status:success',
                                "context:#{saml_response&.authn_context}",
                                VERSION_TAG])
      when :failure
        tag = failure_tag.to_s.starts_with?('error:') ? failure_tag : "error:#{failure_tag}"
        StatsD.increment(STATSD_SSO_CALLBACK_KEY,
                         tags: ['status:failure',
                                "context:#{saml_response&.authn_context}",
                                VERSION_TAG])
        StatsD.increment(STATSD_SSO_CALLBACK_FAILED_KEY, tags: [tag, VERSION_TAG])
      when :failed_unknown
        StatsD.increment(STATSD_SSO_CALLBACK_KEY,
                         tags: ['status:failure', 'context:unknown', VERSION_TAG])
        StatsD.increment(STATSD_SSO_CALLBACK_FAILED_KEY, tags: ['error:unknown', VERSION_TAG])
      when :total
        StatsD.increment(STATSD_SSO_CALLBACK_TOTAL_KEY, tags: [VERSION_TAG])
      end
    end

    # rubocop:disable Metrics/ParameterLists
    def handle_callback_error(exc, status, response, level = :error, context = {},
                              code = SAML::Responses::Base::UNKNOWN_OR_BLANK_ERROR_CODE, tag = nil)
      # replaces bundled Sentry error message with specific XML messages
      message = if response.normalized_errors.count > 1 && response.status_detail
                  response.status_detail
                else
                  exc.message
                end
      conditional_log_message_to_sentry(message, level, context, code)
      Rails.logger.info("SessionsController version:v1 saml_callback failure, user_uuid=#{@current_user&.uuid}")
      redirect_to url_service.login_redirect_url(auth: 'fail', code: code) unless performed?
      login_stats(:failure, exc) unless response.nil?
      callback_stats(status, response, tag)
      PersonalInformationLog.create(
        error_class: exc,
        data: {
          request_id: request.uuid,
          payload: response&.response || params[:SAMLResponse]
        }
      )
    end
    # rubocop:enable Metrics/ParameterLists

    def conditional_log_message_to_sentry(message, level, context, code)
      # If our error is that we have multiple mhv ids, this is a case where we won't log in the user,
      # but we give them a path to resolve this. So we don't want to throw an error, and we don't want
      # to pollute Sentry with this condition, but we will still log in case we want metrics in
      # Cloudwatch or any other log aggregator. Additionally, if the user has an invalid message timestamp
      # error, this means they have waited too long in the log in page to progress, so it's not really an
      # appropriate Sentry error
      if code == SAML::UserAttributeError::MULTIPLE_MHV_IDS_CODE || invalid_message_timestamp_error?(message)
        Rails.logger.warn("SessionsController version:v1 context:#{context} message:#{message}")
      else
        log_message_to_sentry(message, level, extra_context: context)
      end
    end

    def invalid_message_timestamp_error?(message)
      message.match(FIM_INVALID_MESSAGE_TIMESTAMP)
    end

    def set_cookies
      Rails.logger.info('SSO: LOGIN', sso_logging_info)
      set_api_cookie!
    end

    def after_login_actions
      Login::AfterLoginActions.new(@current_user).perform
      log_persisted_session_and_warnings
    end

    def log_persisted_session_and_warnings
      obscure_token = Session.obscure_token(@session_object.token)
      Rails.logger.info("Logged in user with id #{@session_object&.uuid}, token #{obscure_token}")
      # We want to log when SSNs do not match between MVI and SAML Identity. And might take future
      # action if this appears to be happening frequently.
      if current_user.ssn_mismatch?
        additional_context = StringHelpers.heuristics(current_user.identity.ssn, current_user.ssn_mpi)
        log_message_to_sentry(
          'SessionsController version:v1 message:SSN from MPI Lookup does not match UserIdentity cache',
          :warn,
          identity_compared_with_mpi: additional_context
        )
      end
    end

    def html_escaped_relay_state
      JSON.parse(CGI.unescapeHTML(params[:RelayState] || '{}'))
    end

    def originating_request_id
      html_escaped_relay_state['originating_request_id']
    rescue
      'UNKNOWN'
    end

    def url_service(force_authn = true)
      @url_service ||= SAML::PostURLService.new(saml_settings(force_authn: force_authn),
                                                session: @session_object,
                                                user: current_user,
                                                params: params,
                                                loa3_context: LOA::IDME_LOA3)
    end
  end
end
