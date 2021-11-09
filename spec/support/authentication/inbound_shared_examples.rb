# frozen_string_literal: true

module Authentication
  module InboundSharedExamples
    def navigate_through_eauth
      visit 'https://sqa.eauth.va.gov/accessva/'
      find('h4', text: 'I am a Veteran').click
      find(:xpath, "//img[@alt='VHIC Self-Service logo']").click
    end

    RSpec.shared_examples 'logs in inbound ID.me user from eauth' do |email, password|
      it 'logs in inbound idme user from eauth' do
        navigate_through_eauth

        click_on 'Sign in with ID.me'
        click_on 'Accept'

        fill_in 'Email', with: email
        fill_in 'Password', with: password
        click_button 'Sign in to ID.me'

        click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')
        click_button 'Continue' if has_content?('COMPLETE YOUR SIGN IN')

        # Finding this element ensures that we wait for redirect before visiting staging.va.gov
        find('a', text: 'Veteran Health Identification Card (VHIC)')

        visit '/'
        expect_user_logged_in
      end
    end

    RSpec.shared_examples 'logs in inbound DS Logon user from eauth' do |username, password|
      it 'logs in inbound dslogon user from eauth' do
        navigate_through_eauth

        click_on 'Sign in with DS Logon'
        click_on 'Accept'

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

        # Finding this element ensures that we wait for redirect before visiting staging.va.gov
        find('a', text: 'Veteran Health Identification Card (VHIC)')

        visit '/'
        expect_user_logged_in
      end
    end

    RSpec.shared_examples 'logs in inbound MHV user from eauth' do |username, password|
      it 'logs in inbound mhv user from eauth' do
        navigate_through_eauth

        click_on 'Sign in with My HealtheVet'
        click_on 'Accept'

        fill_in 'My HealtheVet User ID', with: username
        fill_in 'My HealtheVet Password', with: password
        click_button 'Sign in'

        click_button 'Continue' if has_content?('Complete your sign in')
        click_button 'Continue' if has_content?('Complete your sign in')

        # Finding this element ensures that we wait for redirect before visiting staging.va.gov
        find('a', text: 'Veteran Health Identification Card (VHIC)')

        visit '/'
        expect_user_logged_in
      end
    end

    RSpec.shared_examples 'logs in inbound DS Logon user from ebenefits' do |username, password|
      it 'logs in inbound dslogon user from ebenefits' do
        visit 'https://pint.ebenefits.va.gov'
        click_on 'Log in'

        page.check('#consent-checkbox')

        fill_in 'userName', with: username
        find_field('password-clear').click
        fill_in 'password', with: password
        click_button 'Login'
      end
    end
  end
end
