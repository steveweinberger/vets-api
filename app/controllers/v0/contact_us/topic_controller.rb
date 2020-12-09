# frozen_string_literal: true

module V0
  module ContactUs
    class TopicController < ApplicationController
      skip_before_action :authenticate, only: :index
      skip_before_action :verify_authenticity_token

      def index
        render json: STUB_RESPONSE, status: :ok
      end

      STUB_RESPONSE = {
        "topics": [
          {
            "topicName": 'Prosthetics, Med Devices & Sensory Aids',
            "requiredFields": %w[medicalCenterList topicLevelThree]
          },
          {
            "topicName": 'Health/Medical Eligibility & Programs',
            "requiredFields": ['topicLevelThree']
          },
          {
            "topicName": 'Medical Care Issues at Specific Facility',
            "requiredFields": ['medicalCenterList']
          },
          {
            "topicName": 'My HealtheVet',
            "requiredFields": []
          },
          {
            "topicName": 'Vet Center / Readjustment Counseling Service (RCS)',
            "requiredFields": []
          },
          {
            "topicName": 'Women Veterans Health Care',
            "requiredFields": ['topicLevelThree']
          }
        ]
      }.freeze
    end
  end
end
