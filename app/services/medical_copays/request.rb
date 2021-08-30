# frozen_string_literal: true

module MedicalCopays
  ##
  # An object responsible for making HTTP calls to the VBS service
  #
  # @!attribute settings
  #   @return [Config::Options]
  # @!attribute host
  #   @return (see Config::Options#host)
  # @!attribute service_name
  #   @return (see Config::Options#service_name)
  # @!attribute url
  #   @return (see Config::Options#url)
  class Request
    extend Forwardable
    include Common::Client::Concerns::Monitoring

    STATSD_KEY_PREFIX = 'api.medical_copays.request'

    attr_reader :settings

    def_delegators :settings, :base_env, :host, :service_name, :url

    ##
    # Builds a MedicalCopays::Request instance
    #
    # @return [MedicalCopays::Request] an instance of this class
    #
    def self.build
      new
    end

    def initialize
      @settings = Settings.mcp.vbs
    end

    ##
    # Make a HTTP POST call to the VBS service in order to obtain user copays
    #
    # @param path [String]
    # @param params [Hash]
    #
    # @return [Faraday::Response]
    #
    def post(path, params)
      with_monitoring do
        connection.post(path) do |req|
          req.body = Oj.dump(params)
        end
      end
    end

    ##
    # Create a connection object that manages the attributes
    # and the middleware stack for making our HTTP requests to VBS
    #
    # @return [Faraday::Connection]
    #
    def connection
      Faraday.new(url: url, headers: headers) do |conn|
        conn.request :json
        conn.use :breakers
        conn.use Faraday::Response::RaiseError
        conn.response :raise_error, error_prefix: service_name
        conn.response :json
        conn.response :betamocks if mock_enabled?
        conn.adapter Faraday.default_adapter
      end
    end

    ##
    # HTTP request headers for the VBS API
    #
    # @return [Hash]
    #
    def headers
      {
        'Host' => host,
        'Content-Type' => 'application/json'
      }
    end

    ##
    # Betamocks enabled status from settings
    #
    # @return [Boolean]
    #
    def mock_enabled?
      settings.mock || false
    end
  end
end