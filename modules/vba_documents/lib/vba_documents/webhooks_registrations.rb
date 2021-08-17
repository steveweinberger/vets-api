# frozen_string_literal: true

module VBADocuments
  module Registrations
    include Webhooks::Utilities

    WEBHOOK_STATUS_CHANGE_EVENT = 'gov.va.developer.benefits-intake.status_change'

    register_events('gov.va.developer.benefits-intake.status_change',
                    api_name: 'vba_documents-v2',
                    max_retries: Settings.webhooks.registration_max_retries.presence || 3)  do |ltas|
      next_run = if ltas.nil?
                   0.seconds.from_now
                 else
                   Settings.webhooks.registration_next_run_in_minutes.minutes.from_now.presence || 15
                 end
      next_run
    rescue
      15.minutes.from_now
    end
    # todo place documentation outlining structure of failure data.  Something like:
    # {401 => 3, 404 => 2, 501 => 1, 'Faraday::ClientError' => 3, 'total' => 9}
    register_failure_handler(api_name: "vba_documents-v2") do |failure_data|
      r_val = {}
      # failure_data
      # todo put in real impl
      return 1.hour.from_now
    end
  end
end
