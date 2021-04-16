# frozen_string_literal: true

require 'feature_flipper'
require 'common/exceptions'
require 'common/client/errors'
require 'rest-client'
require 'saml/settings_service'
require 'sentry_logging'
require 'oidc/key_service'
require 'okta/user_profile'
require 'okta/service'
require 'jwt'
require 'base64'

class OpenidApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_after_action :set_csrf_header
  before_action :authenticate
  TOKEN_REGEX = /Bearer /.freeze

  private

  def permit_scopes(scopes, actions: [])
    return false unless token.payload

    if actions.empty? || Array.wrap(actions).map(&:to_s).include?(action_name)
      render_unauthorized if (Array.wrap(scopes) & token.payload['scp']).empty?
    end
  end

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    return false if token.blank?

    # Only want to fetch the Okta profile if the session isn't already established and not a CC token
    @session = Session.find(token) unless token.client_credentials_token?
    profile = fetch_profile(token.identifiers.okta_uid) unless token.client_credentials_token? || !@session.nil?
    populate_ssoi_token_payload(profile) if @session.nil? && !profile.nil? && profile.attrs['last_login_type'] == 'ssoi'

    # issued for a client vs a user
    if token.client_credentials_token? || token.ssoi_token?
      if token.payload['scp'].include?('launch/patient')
        launch = fetch_smart_launch_context
        token.payload[:icn] = launch
        token.payload[:launch] = { patient: launch } unless launch.nil?
      end
      if token.payload['scp'].include?('launch')
        launch = fetch_smart_launch_context
        token.payload[:launch] = base64_json?(launch) ? JSON.parse(Base64.decode64(launch)) : { patient: launch }
      end
      return true
    end

    establish_session(profile) if @session.nil?
    return false if @session.nil?

    @current_user = OpenidUser.find(@session.uuid)
  end

  def populate_ssoi_token_payload(profile)
    token.payload['last_login_type'] = 'ssoi'
    token.payload['icn'] = profile.attrs['icn']
    token.payload['npi'] = profile.attrs['npi']
    token.payload['vista_id'] = profile.attrs['VistaId']
  end

  def token_from_request
    auth_request = request.authorization.to_s
    return unless auth_request[TOKEN_REGEX]

    token_string = auth_request.sub(TOKEN_REGEX, '').gsub(/^"|"$/, '')

    if jwt?(token_string)
      Token.new(token_string, fetch_aud)
    else
      # Future block for opaque tokens
      raise error_klass('Invalid token.')
    end
  end

  def base64_json?(launch_string)
    JSON.parse(Base64.decode64(launch_string))
    true
  rescue JSON::ParserError
    false
  end

  def jwt?(token_string)
    JWT.decode(token_string, nil, false, algorithm: 'RS256')
    true
  rescue JWT::DecodeError
    false
  end

  def error_klass(error_detail_string)
    # Errors from the jwt gem (and other dependencies) are reraised with
    # this class so we can exclude them from Sentry without needing to know
    # all the classes used by our dependencies.
    Common::Exceptions::TokenValidationError.new(detail: error_detail_string)
  end

  def establish_session(profile)
    ttl = token.payload['exp'] - Time.current.utc.to_i
    user_identity = OpenidUserIdentity.build_from_okta_profile(uuid: token.identifiers.uuid, profile: profile, ttl: ttl)
    @current_user = OpenidUser.build_from_identity(identity: user_identity, ttl: ttl)
    @session = build_session(ttl)
    @session.save && user_identity.save && @current_user.save
  end

  def token
    @token ||= token_from_request
  end

  def fetch_profile(uid)
    profile_response = Okta::Service.new.user(uid)
    if profile_response.success?
      Okta::UserProfile.new(profile_response.body['profile'])
    else
      log_message_to_sentry('Error retrieving profile for OIDC token', :error,
                            body: profile_response.body)
      raise 'Unable to retrieve user profile'
    end
  end

  def build_session(ttl)
    session = Session.new(token: token.to_s, uuid: token.identifiers.uuid)
    session.expire(ttl)
    session
  end

  def fetch_aud
    Settings.oidc.isolated_audience.default
  end

  def fetch_smart_launch_context
    response = RestClient.get(Settings.oidc.smart_launch_url,
                              { Authorization: 'Bearer ' + token.token_string })
    raise error_klass('Invalid launch context') if response.nil?

    if response.code == 200
      json_response = JSON.parse(response.body)
      json_response['launch']
    end
  rescue
    raise error_klass('Invalid launch context')
  end

  attr_reader :current_user, :session, :scopes
end
