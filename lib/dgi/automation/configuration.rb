# frozen_string_literal: true

require 'dgi/configuration'

module DGI
  module Automation
    class Configuration < DGI::Configuration
      def base_path
        "#{Settings.dgi['veteran-services'].url}/claimType/Chapter33/claimants"
      end

      def service_name
        'DGI/Automation'
      end

      def mock_enabled?
        Settings.dgi['veteran-services'].mock || false
      end
    end
  end
end
