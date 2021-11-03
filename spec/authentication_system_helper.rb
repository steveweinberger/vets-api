# frozen_string_literal: true

require 'rails_helper'
require 'support/authentication/outbound_shared_examples'

RSpec.configure do |config|
  config.before do
    driven_by :selenium_chrome_headless
    Capybara.server = :puma
    Capybara.app_host = 'https://staging.va.gov'
    Capybara.run_server = false # don't start Rack
    Capybara.default_max_wait_time = 15
    VCR.turn_off!

    # Fixes issue with WebMock and Ruby 2.7
    # https://github.com/bblimke/webmock/blob/master/README.md#connecting-on-nethttpstart
    WebMock.allow_net_connect!(net_http_connect_on_start: true)

    config.include Authentication::OutboundSharedExamples, type: :system
  end
end
