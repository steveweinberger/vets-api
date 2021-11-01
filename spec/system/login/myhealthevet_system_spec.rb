# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'MyHealtheVet login', type: :system do
    context 'outbound' do
      context 'LOA1 basic' do
        include_examples 'logs in My HealtheVet user', 'JohnService', ENV['JOHN_SERVICE_PASSWORD']
        include_examples 'logs in My HealtheVet user', 'NonVAPat1', ENV['MHV_LOA1_PASSWORD']
        include_examples 'logs in My HealtheVet user', 'JohnBasic', ENV['MHV_LOA1_PASSWORD']
        include_examples 'logs in My HealtheVet user', 'uncorrtest2', ENV['MHV_LOA1_PASSWORD']
      end
    end
  end
end
