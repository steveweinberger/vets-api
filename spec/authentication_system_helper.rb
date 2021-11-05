# frozen_string_literal: true

require 'rails_helper'
require 'support/authentication/outbound_shared_examples'
require 'support/authentication/inbound_shared_examples'

def expect_user_logged_in
  expect(page).to have_content('My Health')
  expect(page).not_to have_content('Sign in')
end

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: options)
end

RSpec.configure do |config|
  config.before do
    driven_by :chrome_headless
    Capybara.server = :puma
    Capybara.app_host = 'https://staging.va.gov'
    Capybara.run_server = false # don't start Rack
    Capybara.default_max_wait_time = 25
    VCR.turn_off!

    # Fixes issue with WebMock and Ruby 2.7
    # https://github.com/bblimke/webmock/blob/master/README.md#connecting-on-nethttpstart
    WebMock.allow_net_connect!(net_http_connect_on_start: true)

    config.include Authentication::OutboundSharedExamples, type: :system
    config.include Authentication::InboundSharedExamples, type: :system
  end
end
