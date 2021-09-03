# frozen_string_literal: true

module Registrations
  include Webhooks::Utilities
  TEST_EVENT = 'registrations_test_event'
  API_NAME = 'registrations_test_api'
  MAX_RETRIES = 3
  register_events(TEST_EVENT, api_name: API_NAME, max_retries: MAX_RETRIES) do
    30.seconds.from_now
  end

  register_failure_handler(api_name: API_NAME) do |failure_data|
    failure_limit = Thread.current['failure_limit'] || 5
    case failure_data['total']
    when 1..failure_limit
      0.minutes.from_now
    else
      Webhooks::Subscription::BLOCKED_CALLBACK
    end
  end
end
