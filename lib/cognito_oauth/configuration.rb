# frozen_string_literal: true

require 'common/client/configuration/rest'

module CognitoOAuth
  # Configuration for the CognitoOAuth::Service
  #
  # @example set the configuration in the service
  #   configuration IAMSSOeOAuth::Configuration
  #
  class Configuration < Common::Client::Configuration::REST
    # Override the parent's base path
    # @return String the service base path from the environment settings
    #
    def base_path
      Settings.cognito_oauth.base_url
    end

    # Service name for breakers integration
    # @return String the service name
    #
    def service_name
      'CognitoOAuth'
    end

    # Faraday connection object with breakers and json response middleware
    # @return Faraday::Connection connection to make http calls
    #
    def connection
      @connection ||= Faraday.new(
        base_path, headers: base_request_headers, request: request_options) do |conn|
        conn.use :breakers

        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
