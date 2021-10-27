# frozen_string_literal: true

require 'dgi/automation/configuration'
require 'dgi/service'
require 'common/client/base'

module DGI
  module Automation
    class Service < DGI::Service
      configuration DGI::Automation::Configuration

      def post_claimant_info
        with_monitoring do
          perform(
            :post,
            end_point,
            request_body,
            request_headers
          )
        end
      end

      private

      def request_headers
        {
          Authorization: "Bearer #{Settings.dgi.automation.credentials}"
        }
      end

      def end_point
        "#{Settings.dgi.automation.base_url}/claimType/Chapter33/claimants"
      end

      def request_body
        # TODO: Passes Back User SSN in the body
      end
    end
  end
end
