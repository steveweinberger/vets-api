# frozen_string_literal: true

module Mobile
  module V1
    class Appointment < Mobile::V0::Appointment
      redis_config REDIS_CONFIG[:mobile_app_appointments_store_v1]
    end
  end
end
