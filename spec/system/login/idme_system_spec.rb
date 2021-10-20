# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
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
