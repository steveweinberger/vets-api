# frozen_string_literal: true

module Mobile
  module V1
    class AppointmentsController < Mobile::V0::AppointmentsController
    
      private

      def appointments_proxy
        Mobile::V1::Appointments::Proxy.new(@current_user)
      end

      def appointment_class
        Mobile::V1::Appointment
      end
    end
  end
end
