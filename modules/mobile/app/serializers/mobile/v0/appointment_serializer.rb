# frozen_string_literal: true

module Mobile
  module V0
    class AppointmentSerializer
      include FastJsonapi::ObjectSerializer

      attributes :appointment_type,
                 :cancel_id,
                 :comment,
                 :healthcare_provider,
                 :healthcare_service,
                 :location,
                 :minutes_duration,
                 :phone_only,
                 :start_date_local,
                 :start_date_utc,
                 :status,
                 :status_detail,
                 :time_zone,
                 :vetext_id,
                 :reason,
                 :is_covid_vaccine
    end
  end
end
