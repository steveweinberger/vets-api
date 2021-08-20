# frozen_string_literal: true

module Mobile
  module V1
    module Appointments
      class Proxy < Mobile::V0::Appointments::Proxy
        private

        def va_appointments_adapter
          Mobile::V1::Adapters::VAAppointments.new
        end
      end
    end
  end
end
