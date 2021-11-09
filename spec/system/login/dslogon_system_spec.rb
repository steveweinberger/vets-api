# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'DS Logon login', type: :system do
    context 'outbound' do
      context 'LOA2 premium' do
        it 'logs in outbound dslogon user' do
          visit '/'
          click_button 'Sign in'
          click_button 'Sign in with DS Logon'

          dslogon_login_steps('ace.a.mcghee1', ENV['DSLOGON_LOA2_PASSWORD'])

          expect_user_logged_in
        end
      end
    end

    context 'inbound' do
      context 'LOA2 premium' do
        it 'logs in inbound dslogon user from eauth' do
          navigate_through_eauth

          click_on 'Sign in with DS Logon'
          click_on 'Accept'

          dslogon_login_steps('ace.a.mcghee1', ENV['DSLOGON_LOA2_PASSWORD'])

          # Finding this element ensures that we wait for redirect before visiting staging.va.gov
          find('a', text: 'Veteran Health Identification Card (VHIC)')

          visit '/'
          expect_user_logged_in
        end

        it 'logs in inbound dslogon user from ebenefits' do
          visit 'https://pint.ebenefits.va.gov'
          click_on 'Log in'

          page.check('#consent-checkbox')

          dslogon_login_steps('ace.a.mcghee1', ENV['DSLOGON_LOA2_PASSWORD'])

          # Finding this element ensures that we wait for redirect before visiting staging.va.gov
          find('h1', text: 'Welcome, ')

          visit '/'
          expect_user_logged_in
        end
      end
    end
  end
end
