# frozen_string_literal: true

module AuthenticationSharedExamples
  RSpec.shared_examples 'logs in LOA1 ID.me user' do |email|
    it 'logs in loa1 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: email
      fill_in 'Password', with: ENV['LOA1_PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'

      expect(page).to have_content('My Health')
      expect(page).not_to have_content('Sign in')
    end
  end

  RSpec.shared_examples 'logs in LOA3 ID.me user' do |email|
    it 'logs in loa3 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: email
      fill_in 'Password', with: ENV['LOA3_PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'
      click_button 'Continue'

      expect(page).to have_content('My Health')
      expect(page).not_to have_content('Sign in')
    end
  end
end
