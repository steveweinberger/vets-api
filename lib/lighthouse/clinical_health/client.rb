# frozen_string_literal: true


require 'lighthouse/clinical_health/configuration'
require 'lighthouse/clinical_health/jwt_wrapper'

module Lighthouse
  module ClinicalHealth
    # Documentation located at:
    # https://developer.va.gov/explore/health/docs/clinical_health
    class Client < Common::Client::Base
      include Common::Client::Concerns::Monitoring
      configuration Lighthouse::ClinicalHealth::Configuration
      def get_conditions(icn)
        bearer = bearer_token(icn)
        # connection.headers = Configuration.base_request_headers.merge({ "Authorization": "Bearer ${bearer}"} )
        params =
          { 'patient' => icn,
            'clinical-status' => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active',
            'page' => 1,
            '_count' => 30 }

        perform(:get, '/services/fhir/v0/r4/Condition', params, headers = Configuration.base_request_headers.merge({ "Authorization": "Bearer " + bearer }))
      end

      def get_observations(icn)
        bearer = bearer_token(icn)

        params = {
                    'patient': icn,
                    'category': 'vital-signs',
                    'code': '85354-9'
                  }
        perform(:get, 'services/fhir/v0/r4/Observation', params, headers = Configuration.base_request_headers.merge({ "Authorization": "Bearer " + bearer }))
      end

      def get_medications(icn)
      end

      def authenticate(params)
        perform(:post, 'oauth2/health/system/v1/token', URI.encode_www_form(params), headers = { 'Content-Type': 'application/x-www-form-urlencoded' })
      end

      def bearer_token(icn)
        @bearer_token ||= retrieve_bearer_token(icn)
      end

      def retrieve_bearer_token(icn)
        authenticate_as_system(JwtWrapper.new.token, icn)
      end

      def authenticate_as_system(json_web_token, icn)
        bearer_token = authenticate(payload(json_web_token, icn)).body['access_token']
      end

      def payload(json_web_token, icn)
        {
          grant_type: 'client_credentials',
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: json_web_token,
          scope: 'launch/patient patient/Patient.read patient/Observation.read patient/Medication.read patient/Condition.read system/Endpoint.read patient/Practitioner.read',
          launch: icn
        }.as_json
      end
    end
  end
end
