# frozen_string_literal: true

require 'common/client/base'
require 'dgi/eligibility/configuration'
require 'dgi/service'
require 'dgi/eligibility/eligibility_response'
require 'authentication_token_service'

module MebApi
  module DGI
    module Eligibility
      class Service < MebApi::DGI::Service
        configuration MebApi::DGI::Eligibility::Configuration
        STATSD_KEY_PREFIX = 'api.dgi.eligibility'

        def get_eligibility
          with_monitoring do
            headers = request_headers
            options = { timeout: 60 }
            raw_response = perform(:get, end_point, nil, headers, options)

            MebApi::DGI::Eligibility::EligibilityResponse.new(raw_response.status, raw_response)
          end
        end

        private

        def end_point
          'claimant/1111111111/eligibility'
        end

        def json
          nil
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
