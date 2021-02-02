# frozen_string_literal: true

module HealthQuest
  module QuestionnaireManager
    class Factory
      attr_reader :aggregated_data,
                  :appointments,
                  :patient,
                  :questionnaires,
                  :questionnaire_responses,
                  :save_in_progress_data,
                  :appointment_service,
                  :patient_service,
                  :questionnaire_service,
                  :questionnaire_response_service,
                  :user

      def self.manufacture(user)
        new(user)
      end

      def initialize(user)
        @aggregated_data = default_aggregated_data
        @user = user
        @appointment_service = AppointmentService.new(user)
        @patient_service = PatientGeneratedData::Patient::Factory.manufacture(user)
        @questionnaire_service = PatientGeneratedData::Questionnaire::Factory.manufacture(user)
        @questionnaire_response_service = PatientGeneratedData::QuestionnaireResponse::Factory.manufacture(user)
      end

      def all
        get_patient
        get_appointments
        get_questionnaires
        get_questionnaire_responses
        get_sip_data
        compose
      end

      def get_appointments
        @appointments = appointment_service.get_appointments(three_months_ago, one_year_from_now)
      end

      def get_patient; end

      def get_questionnaires; end

      def get_questionnaire_responses; end

      def get_sip_data; end

      def compose; end

      private

      def three_months_ago
        3.months.ago.in_time_zone
      end

      def one_year_from_now
        1.year.from_now.in_time_zone
      end

      def default_aggregated_data
        { data: [] }
      end
    end
  end
end
