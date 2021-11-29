# frozen_string_literal: true

require 'common/client/base'
require 'dgi/automation/configuration'
require 'dgi/service'
require 'dgi/automation/claimant_response'
require 'authentication_token_service'

module MebApi
  module DGI
    module Automation
      class Service < MebApi::DGI::Service
        configuration MebApi::DGI::Automation::Configuration
        STATSD_KEY_PREFIX = 'api.dgi.automation'

        def get_claimant_info
          with_monitoring do
            headers = request_headers
            options = { timeout: 60 }
            raw_response = perform(:post, end_point, @user.ssn.to_s, headers, options)

            MebApi::DGI::Automation::ClaimantResponse.new(raw_response.status, raw_response)
          end
        end

        private

        def end_point
          'claimType/Chapter33/claimants'
        end

        def request_headers
          {
            Authorization: "Bearer #{MebApi::AuthenticationTokenService.call}"
          }
        end
      end
    end
  end
end
