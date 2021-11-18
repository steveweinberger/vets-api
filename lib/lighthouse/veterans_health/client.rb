# frozen_string_literal: true

require 'lighthouse/veterans_health/configuration'
require 'lighthouse/veterans_health/jwt_wrapper'

module Lighthouse
  module VeteransHealth
    # Documentation located at:
    # https://developer.va.gov/explore/health/docs/clinical_health
    class Client < Common::Client::Base
      include Common::Client::Concerns::Monitoring
      configuration Lighthouse::VeteransHealth::Configuration

      def get_request(resource, icn)
        bearer = bearer_token(icn)
        send("get_#{resource}", bearer, icn)
      end

      def get_conditions(bearer, icn)
        params =
          { 'patient' => icn,
            'clinical-status' => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active',
            'page' => 1,
            '_count' => 30 }

        perform(:get, '/services/fhir/v0/r4/Condition', params, Configuration.base_request_headers.merge({ "Authorization": "Bearer #{bearer}" }))
      end

      def get_observations(bearer, icn)
        params = {
                    'patient': icn,
                    'category': 'vital-signs',
                    'code': '85354-9'
                  }
        perform(:get, 'services/fhir/v0/r4/Observation', params, headers = Configuration.base_request_headers.merge({ "Authorization": "Bearer " + bearer }))
      end

      def get_medications(bearer, icn)
        params = {
          'patient': icn
        }
        perform(:get, 'services/fhir/v0/r4/MedicationRequest', params, headers = Configuration.base_request_headers.merge({ "Authorization": "Bearer " + bearer }))
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
        return authenticate(payload(json_web_token, icn)).body['access_token']
      end

      def payload(json_web_token, icn)
        {
          grant_type: 'client_credentials',
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: json_web_token,
          scope: 'launch/patient patient/Patient.read patient/Observation.read patient/Medication.read patient/MedicationRequest.read patient/Condition.read system/Endpoint.read patient/Practitioner.read',
          launch: icn
        }.as_json
      end
    end
  end
end
