# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
    context 'outbound' do
      context 'LOA1' do
        include_examples 'logs in outbound ID.me user', 'joe.niquette+loa1idmstaging@oddball.io', ENV['IDME_LOA1_PASSWORD']
      end

      context 'LOA3' do
        include_examples 'logs in outbound ID.me user', 'vets.gov.user+24@gmail.com', ENV['IDME_LOA3_PASSWORD']
        include_examples 'logs in outbound ID.me user', 'ssoissoetesting+SPO1@gmail.com', ENV['IDME_LOA3_CERNER_PASSWORD']
      end
    end

    context 'inbound' do
      context 'LOA3' do
        it 'logs in inbound idme user from eauth' do
          navigate_through_eauth

          click_on 'Sign in with ID.me'
          click_on 'Accept'

          idme_login_steps('vets.gov.user+24@gmail.com', ENV['IDME_LOA3_PASSWORD'])

          # Finding this element ensures that we wait for redirect before visiting staging.va.gov
          find('a', text: 'Veteran Health Identification Card (VHIC)')

          visit '/'
          expect_user_logged_in
        end

        it 'logs in inbound idme user from unified login' do
          visit 'https://mhv-syst.myhealth.va.gov/mhv-portal-web/home'
          click_on 'Sign in'
          click_on 'Try the new Unified VA Login'
          click_on 'Sign in with ID.me'

          idme_login_steps('vets.gov.user+24@gmail.com', ENV['IDME_LOA3_PASSWORD'])

          # Finding this element ensures that we wait for redirect before visiting staging.va.gov
          find('a', text: 'Go to My HealtheVet')

          visit '/'
          expect_user_logged_in
        end
      end
    end
  end
end
