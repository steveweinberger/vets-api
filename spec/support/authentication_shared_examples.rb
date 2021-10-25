# frozen_string_literal: true

module AuthenticationSharedExamples
  def expect_logged_in_home_screen
    expect(page).to have_content('My Health')
    expect(page).not_to have_content('Sign in')
  end

  RSpec.shared_examples 'logs in LOA1 ID.me user' do |email|
    it 'logs in idme loa1 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: email
      fill_in 'Password', with: ENV['IDME_LOA1_PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'

      expect_logged_in_home_screen
    end
  end

  RSpec.shared_examples 'logs in LOA3 ID.me user' do |email|
    it 'logs in idme loa3 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'
      fill_in 'Email', with: email
      fill_in 'Password', with: ENV['IDME_LOA3_PASSWORD']
      click_button 'Sign in to ID.me'
      click_button 'Continue'
      click_button 'Continue'

      expect_logged_in_home_screen
    end
  end

  RSpec.shared_examples 'logs in DS Logon LOA2 user' do |username|
    it 'logs in dslogon loa2 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with DS Logon'

      fill_in 'userName', with: username
      find_field('password-clear').click
      fill_in 'password', with: ENV['DSLOGON_LOA2_PASSWORD']
      click_button 'Login'

      find(:xpath, "//img[@alt='tiger-relaxing.png']").click
      click_button 'Continue'

      click_button 'Continue' if has_content?('Contact Information Verification')

      click_button 'Continue' if has_content?('Enter a code from your device')

      # Confirm email address page
      click_link 'Complete confirmation' if has_link?('Complete confirmation')

      expect_logged_in_home_screen
    end
  end

  RSpec.shared_examples 'logs in My HealtheVet LOA1 user' do |username, password|
    it 'logs in mhv loa1 user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with My HealtheVet'

      fill_in 'My HealtheVet User ID', with: username
      fill_in 'My HealtheVet Password', with: password
      click_button 'Sign in'
    end
  end
end
