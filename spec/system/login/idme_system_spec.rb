# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'ID.me login', type: :system do
    context 'outbound' do
      context 'LOA1' do
        include_examples 'logs in outbound ID.me user', 'joe.niquette+loa1idmstaging@oddball.io', ENV['IDME_LOA1_PASSWORD']
        include_examples 'logs in outbound ID.me user', 'joe.niquette+idmetest5@oddball.io', ENV['IDME_LOA1_PASSWORD']
      end

      context 'LOA3' do
        include_examples 'logs in outbound ID.me user', 'ssoissoetesting+SPO1@gmail.com', ENV['IDME_LOA3_PASSWORD']
        include_examples 'logs in outbound ID.me user', 'ssoissoetesting+spokane1@gmail.com', ENV['IDME_LOA3_PASSWORD']
      end
    end

    context 'inbound' do
      context 'LOA3' do
        include_examples 'logs in inbound ID.me user from eauth', 'ssoissoetesting+SPO1@gmail.com', ENV['IDME_LOA3_PASSWORD']
        include_examples 'logs in inbound ID.me user from eauth', 'ssoissoetesting+spokane1@gmail.com', ENV['IDME_LOA3_PASSWORD']
      end
    end
  end
end
