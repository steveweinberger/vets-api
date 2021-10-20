# frozen_string_literal: true

require 'rails_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
    before do
      driven_by :selenium_chrome_headless
      Capybara.server = :puma
      Capybara.app_host = 'https://staging.va.gov'
      Capybara.run_server = false # don't start Rack
      Capybara.default_max_wait_time = 15
      VCR.turn_off!

      # Fixes issue with WebMock and Ruby 2.7
      # https://github.com/bblimke/webmock/blob/master/README.md#connecting-on-nethttpstart
      WebMock.allow_net_connect!(net_http_connect_on_start: true)
    end

    it 'can log in an LOA3 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: ENV['EMAIL']
      fill_in 'Password', with: ENV['PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'
      click_button 'Continue'

      expect(page).to have_content('My Health')
      expect(page).not_to have_content('Sign in')
    end

    it 'can log in an LOA1 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: ENV['EMAIL']
      fill_in 'Password', with: ENV['PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'
      click_button 'Continue'
      click_button 'Allow' if has_button?('Allow')

      expect(page).to have_content('My Health')
      expect(page).not_to have_content('Sign in')
    end
  end
end
