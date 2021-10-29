# frozen_string_literal: true

require 'dgi/automation/configuration'
require 'dgi/service'
require 'common/client/base'

module DGI
  module Automation
    class Service < DGI::Service
      configuration DGI::Automation::Configuration

      def post_claimant_info(json)
          headers = request_headers
          options = { timeout: 60 }
          perform(:post, end_point, json, headers, options)
      end

      private

      def end_point
        "#{Settings.dgi['veteran-services'].url}/claimType/Chapter33/claimants"
      end

      def json
        { "ssn": '539139735' }
        # nil

        # TODO: Passes Back User SSN in the body
      end

      def token_string
        'eyJhbGciOiJSUzUxMiJ9.eyJhcHBOYW1lIjoidmV0LWJpby1lYXBpIiwidXNlclR5cGUiOiJTVEFGRiIsInN0YXRpb25JZCI6MTIzLCJpZCI6ImFiY2QxMjM0Iiwic3ViIjoiZGdpLXZldC1iaW8tc2VydmljZSIsImF1ZCI6InZldC1iaW8tbXVsZS1lYXBpIiwiaXNzIjoiREdJLVZBLUJHIiwiaWF0IjoxNjMzNjE2NjQ0LCJleHAiOjE2MzM2MTg1NjR9.D0TMEQuMRzq39TapgKGDV0TtvqAjBBRJNBg9Db-Sb8GhhAXylT0SrJfjhld4jJwzcCsnysnRAY1dXoZIUfHC398Cs4kHQOE9dWdlAEM03_ENOPlx48cCu-KDsZj1AveBSD5X89SU0X_105Y1Umh9WpHRY6ogkkQKhuIKngD3R1HNgz6Lr2zPHxKBw0thb_v09maFLI8kdBM1RM_lQp0jcjbp3ji9xgglbk1XDoqvcxAAJ74WlvU-y9PO_sxA33hFQFRhXT3fQHyA5qYKwLrtZFgVvSNY-sTLomCScBN2xcEnVbxUKkBgXL-jy-Mp36OJAvaQucNM1UP42MzEw3vgxQ'
      end

      def request_headers
        {
          Authorization: "Bearer #{token_string}"
        }
      end
    end
  end
end
