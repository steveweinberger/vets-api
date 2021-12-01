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

    RSpec.shared_examples 'logs in outbound Login.gov user' do |email, password, mfa_key|
      it 'logs in outbound logingov user' do
        visit '/'
        click_button 'Sign in'
        click_on 'Login.gov'

        fill_in 'Email address', with: email
        fill_in 'Password', with: password
        click_button 'Sign in'

        # We're using ROTP library to generate MFA security code using the
        # key we received when creating the account
        totp = ROTP::TOTP.new(mfa_key)
        fill_in 'One-time security code', with: totp.now
        click_button 'Submit'

        expect_user_logged_in
      end
    end
  end
end
