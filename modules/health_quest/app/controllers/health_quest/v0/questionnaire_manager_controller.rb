# frozen_string_literal: true

module HealthQuest
  module V0
    class QuestionnaireManagerController < HealthQuest::V0::BaseController
      def index
        appointments =
          AppointmentService.new(current_user)
                            .get_appointments(6.months.ago.in_time_zone, 6.months.from_now.in_time_zone)

        render json: appointments
      end
    end
  end
end
