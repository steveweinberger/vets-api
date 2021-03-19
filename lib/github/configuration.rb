# frozen_string_literal: true

require 'common/client/configuration/rest'

module GitHub
  class Configuration < Common::Client::Configuration::REST
    def base_path
      Settings.github.url
    end

    def service_name
      'Github'
    end

    def self.base_request_headers
      super.merge('Accept' => 'application/vnd.github.v3+json')
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers) do |conn|
      end
    end
  end
end
