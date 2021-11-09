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
  end
end
