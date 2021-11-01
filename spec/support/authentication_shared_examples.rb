# frozen_string_literal: true

module AuthenticationSharedExamples
  def expect_logged_in_home_screen
    expect(page).to have_content('My Health')
    expect(page).not_to have_content('Sign in')
  end

  RSpec.shared_examples 'logs in outbound ID.me user' do |email, password|
    it 'logs in outbound idme user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with ID.me'

      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in to ID.me'

      click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')
      click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')

      expect_logged_in_home_screen
    end
  end

  RSpec.shared_examples 'logs in outbound DS Logon user' do |username, password|
    it 'logs in outbound dslogon user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with DS Logon'

      fill_in 'userName', with: username
      find_field('password-clear').click
      fill_in 'password', with: password
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

  RSpec.shared_examples 'logs in outbound My HealtheVet user' do |username, password|
    it 'logs in outbound mhv user' do
      visit '/'
      click_button 'Sign in'
      click_button 'Sign in with My HealtheVet'

      fill_in 'My HealtheVet User ID', with: username
      fill_in 'My HealtheVet Password', with: password
      click_button 'Sign in'

      click_button 'Continue' if has_content?('Complete your sign in')
      click_button 'Continue' if has_content?('Complete your sign in')

      expect_logged_in_home_screen
    end
  end
end
