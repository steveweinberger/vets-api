# frozen_string_literal: true

require 'authentication_system_helper'
require 'rotp'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'Login.gov login', type: :system do
    context 'outbound' do
      include_examples('logs in outbound Login.gov user',
                       'joe.niquette+lgovial1a@oddball.io',
                       ENV['LOGINGOV_IAL1_PASSWORD'],
                       ENV['MFA_IAL1_KEY'])

      include_examples('logs in outbound Login.gov user',
                       'joe.niquette+lgovial2a@oddball.io',
                       ENV['LOGINGOV_IAL2_PASSWORD'],
                       ENV['MFA_IAL2_KEY'])
    end
  end
end
