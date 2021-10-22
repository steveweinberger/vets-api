# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
    context 'LOA1' do
      include_examples 'logs in LOA1 ID.me user', 'joe.niquette+loa1idmstaging@oddball.io'
      include_examples 'logs in LOA1 ID.me user', 'joe.niquette+idmetest5@oddball.io'
    end

    context 'LOA3' do
      include_examples 'logs in LOA3 ID.me user', 'ssoissoetesting+SPO1@gmail.com'
      include_examples 'logs in LOA3 ID.me user', 'ssoissoetesting+spokane1@gmail.com'
    end
  end
end
