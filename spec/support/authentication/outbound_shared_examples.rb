# frozen_string_literal: true

module Authentication
  module OutboundSharedExamples
    RSpec.shared_examples 'logs in outbound ID.me user' do |email, password|
      it 'logs in outbound idme user' do
        visit '/'
        click_button 'Sign in'
        click_button 'Sign in with ID.me'

        idme_login_steps(email, password)

        expect_user_logged_in
      end
    end

    RSpec.shared_examples 'logs in outbound My HealtheVet user' do |username, password|
      it 'logs in outbound mhv user' do
        visit '/'
        click_button 'Sign in'
        click_button 'Sign in with My HealtheVet'

        mhv_login_steps(username, password)

        expect_user_logged_in
      end
    end
  end
end
