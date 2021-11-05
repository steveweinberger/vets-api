# frozen_string_literal: true

module Authentication
  module InboundSharedExamples
    def expect_logged_in_home_screen
      expect(page).not_to have_content('Sign in')
      visit 'https://staging-api.va.gov/v0/user'
      expect(page).to have_content('account_uuid')
    end

    RSpec.shared_examples 'logs in inbound ID.me user from eauth' do |email, password|
      it 'logs in inbound idme user from eauth' do
        visit 'https://sqa.eauth.va.gov/accessva/'
        find('h4', text: 'I am a Veteran').click
        find(:xpath, "//img[@alt='VHIC Self-Service logo']").click

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
        expect_logged_in_home_screen
      end
    end
  end
end
