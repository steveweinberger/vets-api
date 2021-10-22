# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
    context 'LOA1' do
      include_examples 'logs in LOA1 ID.me user', 'joe.niquette+loa1idmstaging@oddball.io'
      include_examples 'logs in LOA1 ID.me user', 'joe.niquette+idmetest5@oddball.io'
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
      click_button 'Allow' if has_button?('Allow')

      expect_logged_in_home_screen
    end
  end
end
