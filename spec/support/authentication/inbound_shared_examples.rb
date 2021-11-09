# frozen_string_literal: true

module Authentication
  module InboundSharedExamples
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
  end
end
