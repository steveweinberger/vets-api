# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'MyHealtheVet login', type: :system do
    context 'outbound' do
      context 'LOA1 basic' do
        include_examples 'logs in outbound My HealtheVet user', 'dskevin1', ENV['MHV_LOA1_PASSWORD']
      end

      context 'LOA3 premium' do
        include_examples 'logs in outbound My HealtheVet user', 'vets250', ENV['MHV_LOA3_PASSWORD']
      end
    end

    context 'inbound' do
      context 'LOA3 premium' do
        it 'logs in inbound mhv user from eauth' do
          navigate_through_eauth

          click_on 'Sign in with My HealtheVet'
          click_on 'Accept'

          mhv_login_steps('vets250', ENV['MHV_LOA3_PASSWORD'])

          # Finding this element ensures that we wait for redirect before visiting staging.va.gov
          find('a', text: 'Veteran Health Identification Card (VHIC)')

          visit '/'
          expect_user_logged_in
        end
      end
    end
  end
end
