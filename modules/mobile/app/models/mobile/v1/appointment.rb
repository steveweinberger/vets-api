# frozen_string_literal: true

module Mobile
  module V1
    class Appointment < Mobile::V0::Appointment
      redis_config REDIS_CONFIG[:mobile_app_appointments_store_v1]

      STATUS_TYPE = Types::String.enum(
        'BOOKED',
        'CANCELLED BY CLINIC & AUTO RE-BOOK',
        'CANCELLED BY CLINIC',
        'CANCELLED BY PATIENT & AUTO-REBOOK',
        'CANCELLED BY PATIENT',
        'HIDDEN'
      )

      attribute :status, STATUS_TYPE
    end
  end
end
