# frozen_string_literal: true

module HealthQuest
  module QuestionnaireManager
    class Factory
      attr_reader :appointments,
                  :patient,
                  :appointment_service,
                  :patient_service,
                  :questionnaire_service,
                  :questionnaire_response_service,
                  :questionnaires,
                  :user

      def self.manufacture(user)
        new(user)
      end

      def initialize(user)
        @user = user
        @appointment_service = AppointmentService.new(user)
        @patient_service = PatientGeneratedData::Patient::Factory.manufacture(user)
        @questionnaire_service = PatientGeneratedData::Questionnaire::Factory.manufacture(user)
        @questionnaire_response_service = PatientGeneratedData::QuestionnaireResponse::Factory.manufacture(user)
      end

      def all
        get_or_create_patient
        get_appointments
        get_questionnaires
        get_questionnaire_responses
      end

      def get_appointments
        @appointments = appointment_service.get_appointments(three_months_ago, one_year_from_now)
      end

      def get_or_create_patient; end

      def get_questionnaires; end

      def get_questionnaire_responses; end

      private

      def three_months_ago
        3.months.ago.in_time_zone
      end

      def one_year_from_now
        1.year.from_now.in_time_zone
      end
    end
  end
end
