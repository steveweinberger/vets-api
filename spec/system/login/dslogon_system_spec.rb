# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'DS Logon login', type: :system do
    it 'can login a DS Logon Premium user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with DS Logon'

      fill_in 'userName', with: ENV['DS_PREMIUM_USERNAME']
      find_field('password-clear').click
      fill_in 'password', with: ENV['PASSWORD']
      click_button 'Login'

      find(:xpath, "//img[@alt='tiger-relaxing.png']").click
      click_button 'Continue'

      click_button 'Continue' if has_content?('Contact Information Verification')

      expect_logged_in_home_screen
    end
  end
end
