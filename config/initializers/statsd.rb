# frozen_string_literal: true

StatsD.logger = Logger.new 'log/statsd.log' if Rails.env.development?

require 'caseflow/service'
require 'central_mail/service'
require 'emis/service'
require 'evss/service'
require 'gibft/service'
require 'iam_ssoe_oauth/session_manager'
require 'mpi/service'
require 'saml/errors'
require 'saml/responses/base'
require 'saml/user'
require 'stats_d_metric'
require 'search/service'
require 'search_click_tracking/service'
require 'search_typeahead/service'
require 'va_profile/exceptions/parser'
require 'va_profile/service'
require 'va_notify/service'

Rails.application.reloader.to_prepare do
  # Initialize session controller metric counters at 0
  LOGIN_ERRORS = SAML::Responses::Base::ERRORS.values +
                 UserSessionForm::ERRORS.values +
                 SAML::UserAttributeError::ERRORS.values
  %w[v0 v1].each do |v|
    StatsD.increment(V1::SessionsController::STATSD_SSO_CALLBACK_TOTAL_KEY, 0,
                     tags: ["version:#{v}"])
    StatsD.increment(V1::SessionsController::STATSD_LOGIN_NEW_USER_KEY, 0,
                     tags: ["version:#{v}"])
    V1::SessionsController::REDIRECT_URLS.each do |t|
      StatsD.increment(V1::SessionsController::STATSD_SSO_NEW_KEY, 0,
                       tags: ["version:#{v}", "context:#{t}"])
      StatsD.increment(V1::SessionsController::STATSD_LOGIN_STATUS_SUCCESS, 0,
                       tags: ["version:#{v}", "context:#{t}"])

      LOGIN_ERRORS.each do |err|
        StatsD.increment(V1::SessionsController::STATSD_LOGIN_STATUS_FAILURE, 0,
                         tags: ["version:#{v}", "context:#{t}", "error:#{err[:code]}"])
      end
    end
    %w[success failure].each do |s|
      (SAML::User::AUTHN_CONTEXTS.keys + [SAML::User::UNKNOWN_AUTHN_CONTEXT]).each do |ctx|
        StatsD.increment(V1::SessionsController::STATSD_SSO_CALLBACK_KEY, 0,
                         tags: ["version:#{v}", "status:#{s}", "context:#{ctx}"])
      end
    end
    (SAML::User::AUTHN_CONTEXTS.keys + [SAML::User::UNKNOWN_AUTHN_CONTEXT]).each do |ctx|
      V1::SessionsController::REDIRECT_URLS.each do |t|
        StatsD.increment(V1::SessionsController::STATSD_SSO_SAMLREQUEST_KEY, 0,
                         tags: ["version:#{v}", "context:#{ctx}", "type:#{t}"])
        StatsD.increment(V1::SessionsController::STATSD_SSO_SAMLRESPONSE_KEY, 0,
                         tags: ["version:#{v}", "context:#{ctx}", "type:#{t}"])
        StatsD.increment(V1::SessionsController::STATSD_SSO_SAMLTRACKER_KEY, 0,
                         tags: ["version:#{v}", "context:#{ctx}", "type:#{t}"])
      end
    end
    LOGIN_ERRORS.each do |err|
      StatsD.increment(V1::SessionsController::STATSD_SSO_CALLBACK_FAILED_KEY, 0,
                       tags: ["version:#{v}", "error:#{err[:tag]}"])
    end
  end

  # init GiBillStatus stats to 0
  StatsD.increment(V0::Post911GIBillStatusesController::STATSD_GI_BILL_TOTAL_KEY, 0)
  StatsD.increment(V0::Post911GIBillStatusesController::STATSD_GI_BILL_FAIL_KEY, 0, tags: ['error:unknown'])
  StatsD.increment(V0::Post911GIBillStatusesController::STATSD_GI_BILL_FAIL_KEY, 0, tags: ['error:scheduled_downtime'])
  EVSS::GiBillStatus::GiBillStatusResponse::KNOWN_ERRORS.each_value do |error_val|
    StatsD.increment(V0::Post911GIBillStatusesController::STATSD_GI_BILL_FAIL_KEY, 0, tags: ["error:#{error_val}"])
  end

  # init letters/pciu address
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_letters.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_letters.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_letter_beneficiary.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_letter_beneficiary.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_countries.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_countries.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_states.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_states.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_address.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.get_address.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.update_address.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.update_address.fail", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.policy.success", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.policy.failure", 0)

  # init caseflow
  StatsD.increment("#{Caseflow::Service::STATSD_KEY_PREFIX}.get_appeals.total", 0)
  StatsD.increment("#{Caseflow::Service::STATSD_KEY_PREFIX}.get_appeals.fail", 0)

  # init  mvi
  StatsD.increment("#{MPI::Service::STATSD_KEY_PREFIX}.find_profile.total", 0)
  StatsD.increment("#{MPI::Service::STATSD_KEY_PREFIX}.find_profile.fail", 0)

  # init Vet360
  VAProfile::Exceptions::Parser.instance.known_keys.each do |key|
    StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.exceptions", 0, tags: ["exception:#{key}"])
  end
  StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.total_operations", 0)
  StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.posts_and_puts.success", 0)
  StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.posts_and_puts.failure", 0)
  StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.init_vet360_id.success", 0)
  StatsD.increment("#{VAProfile::Service::STATSD_KEY_PREFIX}.init_vet360_id.failure", 0)

  # init eMIS
  StatsD.increment("#{EMIS::Service::STATSD_KEY_PREFIX}.edipi", 0, tags: ['present:true', 'present:false'])
  StatsD.increment("#{EMIS::Service::STATSD_KEY_PREFIX}.service_history", 0, tags: ['present:true', 'present:false'])

  # init CentralMail
  StatsD.increment("#{CentralMail::Service::STATSD_KEY_PREFIX}.upload.total", 0)
  StatsD.increment("#{CentralMail::Service::STATSD_KEY_PREFIX}.upload.fail", 0)

  # init SentryJob error monitoring
  StatsD.increment(SentryJob::STATSD_ERROR_KEY, 0)

  # init Search
  StatsD.increment("#{Search::Service::STATSD_KEY_PREFIX}.exceptions", 0, tags: ['exception:429'])

  # init Search Typeahead
  StatsD.increment("#{SearchTypeahead::Service::STATSD_KEY_PREFIX}.exceptions", 0, tags: ['exception:400'])

  # init SearchClickTracking
  StatsD.increment("#{SearchClickTracking::Service::STATSD_KEY_PREFIX}.exceptions", 0, tags: ['exception:400'])

  # init Form1010cg
  StatsD.increment(Form1010cg::Auditor.metrics.submission.attempt, 0)
  StatsD.increment(Form1010cg::Auditor.metrics.submission.success, 0)
  StatsD.increment(Form1010cg::Auditor.metrics.submission.failure.client.data, 0)
  StatsD.increment(Form1010cg::Auditor.metrics.submission.failure.client.qualification, 0)
  StatsD.increment(Form1010cg::Auditor.metrics.pdf_download, 0)

  # init form 526 - disability compenstation
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.submit_form526.total", 0)
  StatsD.increment("#{EVSS::Service::STATSD_KEY_PREFIX}.submit_form526.fail", 0)

  %w[try success non_retryable_error retryable_error exhausted].each do |str|
    StatsD.increment("#{EVSS::DisabilityCompensationForm::SubmitForm526::STATSD_KEY_PREFIX}.#{str}", 0)
    StatsD.increment("#{EVSS::DisabilityCompensationForm::SubmitUploads::STATSD_KEY_PREFIX}.#{str}", 0)
    StatsD.increment("#{CentralMail::SubmitForm4142Job::STATSD_KEY_PREFIX}.#{str}", 0)
    StatsD.increment("#{EVSS::DisabilityCompensationForm::SubmitForm0781::STATSD_KEY_PREFIX}.#{str}", 0)
    StatsD.increment("#{EVSS::DisabilityCompensationForm::SubmitForm8940::STATSD_KEY_PREFIX}.#{str}", 0)
    StatsD.increment("#{EVSS::DisabilityCompensationForm::SubmitForm526Cleanup::STATSD_KEY_PREFIX}.#{str}", 0)
  end
  StatsD.increment(Form526ConfirmationEmailJob::STATSD_ERROR_NAME, 0)
  StatsD.increment(Form526ConfirmationEmailJob::STATSD_SUCCESS_NAME, 0)

  # init Higher Level Review

  # Notice of Disagreement
  StatsD.increment("#{DecisionReview::SubmitUpload::STATSD_KEY_PREFIX}.success", 0)
  StatsD.increment("#{DecisionReview::SubmitUpload::STATSD_KEY_PREFIX}.error", 0)

  # init VaNotify
  StatsD.increment("#{VaNotify::Service::STATSD_KEY_PREFIX}.send_email.total", 0)
  StatsD.increment("#{VaNotify::Service::STATSD_KEY_PREFIX}.send_email.fail", 0)

  ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_, _, _, _, payload|
    tags = ["controller:#{payload.dig(:params, :controller)}", "action:#{payload.dig(:params, :action)}",
            "status:#{payload[:status]}"]
    StatsD.measure('api.request.db_runtime', payload[:db_runtime].to_i, tags: tags)
    StatsD.measure('api.request.view_runtime', payload[:view_runtime].to_i, tags: tags)
  end

  # init gibft
  StatsD.increment("#{Gibft::Service::STATSD_KEY_PREFIX}.submit.total", 0)
  StatsD.increment("#{Gibft::Service::STATSD_KEY_PREFIX}.submit.fail", 0)

  all_keys = StatsDMetric.keys
  all_keys.each do |key|
    StatsD.increment(key.to_s, 0)
  end

  # init Facilities Jobs
  StatsD.increment('shared.sidekiq.default.Facilities_InitializingErrorMetric.error', 0)

  ActiveSupport::Notifications.subscribe(
    'facilities.ppms.request.faraday'
  ) do |_name, start_time, end_time, _id, payload|
    payload_statuses = ["http_status:#{payload.status}"]
    StatsD.increment('facilities.ppms.response.failures', tags: payload_statuses) unless payload.success?
    StatsD.increment('facilities.ppms.response.total', tags: payload_statuses)

    duration = end_time - start_time

    measurement = case payload[:url].path
                  when /FacilityServiceLocator/
                    'facilities.ppms.facility_service_locator'
                  when /ProviderLocator/
                    'facilities.ppms.provider_locator'
                  when /PlaceOfServiceLocator/
                    'facilities.ppms.place_of_service_locator'
                  when %r{Providers\(\d+\)/ProviderServices}
                    'facilities.ppms.providers.provider_services'
                  when /Providers\(\d+\)/
                    'facilities.ppms.providers'
                  end

    if measurement
      tags = ['facilities.ppms']
      params = Rack::Utils.parse_nested_query payload[:url].query

      if params['radius']
        tags << "facilities.ppms.radius:#{params['radius']}"
        tags << "facilities.ppms.results:#{payload[:body].is_a?(Array) ? payload[:body]&.count : 0}"
      end

      StatsD.measure(measurement, duration, tags: tags)
    end
  end

  ActiveSupport::Notifications.subscribe(
    'facilities.ppms.v1.request.faraday'
  ) do |_name, start_time, end_time, _id, payload|
    payload_statuses = ["http_status:#{payload.status}"]
    StatsD.increment('facilities.ppms.response.failures', tags: payload_statuses) unless payload.success?
    StatsD.increment('facilities.ppms.response.total', tags: payload_statuses)

    duration = end_time - start_time

    measurement = case payload[:url].path
                  when /FacilityServiceLocator/
                    'facilities.ppms.facility_service_locator'
                  when /ProviderLocator/
                    'facilities.ppms.provider_locator'
                  when /PlaceOfServiceLocator/
                    'facilities.ppms.place_of_service_locator'
                  when %r{Providers\(\d+\)/ProviderServices}
                    'facilities.ppms.providers.provider_services'
                  when /Providers\(\d+\)/
                    'facilities.ppms.providers'
                  end

    if measurement
      tags = ['facilities.ppms']
      params = Rack::Utils.parse_nested_query payload[:url].query

      if params['radius']
        count =
          case payload.body
          when Hash
            payload.dig(:body, :value)&.count
          when Array
            payload.body&.count
          else
            0
          end

        tags << "facilities.ppms.radius:#{params['radius']}"
        tags << "facilities.ppms.results:#{count || 0}"
      end

      StatsD.measure(measurement, duration, tags: tags)
    end
  end

  ActiveSupport::Notifications.subscribe(
    'lighthouse.facilities.request.faraday'
  ) do |_, start_time, end_time, _, payload|
    payload_statuses = ["http_status:#{payload.status}"]
    StatsD.increment('facilities.lighthouse.response.failures', tags: payload_statuses) unless payload.success?
    StatsD.increment('facilities.lighthouse.response.total', tags: payload_statuses)

    duration = end_time - start_time
    StatsD.measure('facilities.lighthouse', duration, tags: ['facilities.lighthouse'])
  end

  # IAM SSOe session metrics
  StatsD.set('iam_ssoe_oauth.users', 0)

  IAMSSOeOAuth::SessionManager.extend StatsD::Instrument
  IAMSSOeOAuth::SessionManager.statsd_count_success :create_user_session,
                                                    'iam_ssoe_oauth.create_user_session'
  IAMSSOeOAuth::SessionManager.statsd_measure :create_user_session,
                                              'iam_ssoe_oauth.create_user_session.measure'
  StatsD.increment('iam_ssoe_oauth.create_user_session.success', 0)
  StatsD.increment('iam_ssoe_oauth.create_user_session.failure', 0)
  StatsD.increment('iam_ssoe_oauth.inactive_session', 0)

  %w[IDME MHV DSL].each do |cred|
    StatsD.increment(
      IAMSSOeOAuth::SessionManager::STATSD_OAUTH_SESSION_KEY, 0, tags: ['type:new', "credential:#{cred}"]
    )
    StatsD.increment(
      IAMSSOeOAuth::SessionManager::STATSD_OAUTH_SESSION_KEY, 0, tags: ['type:refresh', "credential:#{cred}"]
    )
  end

  # init VEText Push Notifications
  begin
    VEText::Service.extend StatsD::Instrument
    VEText::Service.statsd_count_success :register,
                                         "#{VEText::Service::STATSD_KEY_PREFIX}.register"
    VEText::Service.statsd_count_success :get_preferences,
                                         "#{VEText::Service::STATSD_KEY_PREFIX}.get_prefs"
    VEText::Service.statsd_count_success :set_preference,
                                         "#{VEText::Service::STATSD_KEY_PREFIX}.set_pref"
    VEText::Service.statsd_count_success :send_notification,
                                         "#{VEText::Service::STATSD_KEY_PREFIX}.send_notification"
    VEText::Service.statsd_count_success :app_sid,
                                         "#{VEText::Service::STATSD_KEY_PREFIX}.app_lookup"
  rescue ArgumentError
    # noop
    # if these are already registered, they will throw - see source
    # https://github.com/Shopify/statsd-instrument/blob/3c9bf8675e97d98ebeb778a146168cc940b2fc8d/lib/statsd/instrument.rb#L262
  end

  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.register.success", 0)
  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.register.failure", 0)

  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.get_prefs.success", 0)
  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.get_prefs.failure", 0)

  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.set_pref.success", 0)
  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.set_pref.failure", 0)

  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.send_notification.success", 0)
  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.send_notification.failure", 0)

  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.app_lookup.success", 0)
  StatsD.increment("#{VEText::Service::STATSD_KEY_PREFIX}.app_lookup.failure", 0)
end
