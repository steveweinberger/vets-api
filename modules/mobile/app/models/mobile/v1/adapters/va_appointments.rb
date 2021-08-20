# frozen_string_literal: true

module Mobile
  module V1
    module Adapters
      class VAAppointments < Mobile::V0::Adapters::VAAppointments
        private

        def status(details, type, start_date)
          status = va?(type) ? details[:current_status] : details.dig(:status, :code)
          return STATUSES[:hidden] if should_hide_status?(start_date.past?, status)
          return status if CANCELLED_STATUS.include?(status)

          STATUSES[:booked]
        end

        def appointment_model
          Mobile::V1::Appointment
        end
      end
    end
  end
end
