# frozen_string_literal: true

require 'uri'
require 'cognito_oauth/configuration'

module CognitoOAuth
  # Class used to connect to AWS Cognito Oauth service which validates tokens
  # and given a valid token returns a set of user traits.
  #
  # @example create a new instance and call the introspect endpoint
  #   token = 'ypXeAwQedpmAy5xFD2u5'
  #   service = CognitoOAuth::Service.new
  #   response = service.post_introspect(token)
  #
  class Service < Common::Client::Base
    configuration CognitoOAuth::Configuration

    USERINFO_PATH = '/oauth2/userInfo'

    # Validate a user's auth token and returns either valid active response with a set
    # of user traits or raise's an unauthorized error if the response comes back as invalid.
    #
    # @token String the auth token for the user
    #
    # @return Hash active user traits
    #
    def post_introspect(token)
      response = perform(
        :get, USERINFO_PATH, nil, { 'Authorization' => "Bearer #{token}" }
      )
      case response.status.to_i
      when 200
        response.body
      when 400
        raise Common::Exceptions::Unauthorized, detail: 'Cognito session request is invalid'
      when 401
        raise Common::Exceptions::Unauthorized, detail: 'Cognito session token is invalid or expired'
      else
        Raven.extra_context(
          url: config.base_path,
          body: response.body
        )
        raise Common::Exceptions::Unauthorized, detail: 'Unknown Cognito error'
      end
    rescue Common::Client::Errors::ClientError => e
      remap_error(e)
    end

    private

    # TODO: Fix these error mappings
    def remap_error(e)
      case e.status
      when 400
        raise Common::Exceptions::BackendServiceException.new('IAM_SSOE_400', detail: e.body)
      when 500
        raise Common::Exceptions::BackendServiceException, 'IAM_SSOE_502'
      else
        raise e
      end
    end
  end
end
