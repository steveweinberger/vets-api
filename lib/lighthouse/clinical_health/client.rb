# frozen_string_literal: true

require 'common/client/base'
require_relative 'configuration'

module Lighthouse
  module ClinicalHealth
    # Documentation located at:
    # https://developer.va.gov/explore/health/docs/clinical_health
    class Client < Common::Client::Base
      configuration Lighthouse::ClinicalHealth::Configuration
      def get_condition(icn)
        params =
          { 'patient' => icn,
            '_id' => 'I2-FOBJ7YQOH3RIQ5UZ6TRM32ZSQA000000',
            'identifier' => 'I2-FOBJ7YQOH3RIQ5UZ6TRM32ZSQA000000',
            'clinical-status' => 'http://terminology.hl7.org/CodeSystem/condition-clinical|active,resolved',
            'page' => 1,
            '_count' => 30 }
        perform(:get, 'Condition', params)
      end
    end
  end
end
