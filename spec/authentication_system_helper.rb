# frozen_string_literal: true

require 'rails_helper'
require 'support/authentication/outbound_shared_examples'

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
    # driven_by :chrome_headless
    driven_by :selenium_chrome
    Capybara.server = :puma
    Capybara.app_host = 'https://staging.va.gov'
    Capybara.run_server = false # don't start Rack
    Capybara.default_max_wait_time = 25
    VCR.turn_off!

    # Fixes issue with WebMock and Ruby 2.7
    # https://github.com/bblimke/webmock/blob/master/README.md#connecting-on-nethttpstart
    WebMock.allow_net_connect!(net_http_connect_on_start: true)

    config.include Authentication::OutboundSharedExamples, type: :system
  end
end

def expect_user_logged_in
  expect(page).to have_content('My Health')
  expect(page).not_to have_content('Sign in')
end

def navigate_through_eauth
  visit 'https://sqa.eauth.va.gov/accessva/'
  find('h4', text: 'I am a Veteran').click
  find(:xpath, "//img[@alt='VHIC Self-Service logo']").click
end

def idme_login_steps(email, password)
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Sign in to ID.me'

  click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')
  click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')
end

def dslogon_login_steps(username, password)
  fill_in 'userName', with: username
  find_field('password-clear').click
  fill_in 'password', with: password
  click_button 'Login'

  find(:xpath, "//img[@alt='tiger-relaxing.png']").click
  click_button 'Continue'

  click_button 'Continue' if has_content?('Contact Information Verification')
  click_button 'Continue' if has_content?('Enter a code from your device')
  click_link 'Complete confirmation' if has_link?('Complete confirmation')
end

def mhv_login_steps(username, password)
  fill_in 'My HealtheVet User ID', with: username
  fill_in 'My HealtheVet Password', with: password
  click_button 'Sign in'

  click_button 'Continue' if has_content?('Complete your sign in')
  click_button 'Continue' if has_content?('Complete your sign in')
end
