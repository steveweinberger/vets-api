# frozen_string_literal: true

require 'rails_helper'

Rspec.describe AuthenticationTokenService do
  describe '.call' do
    let(:token) { described_class.call }

    it 'returns an authentication token' do
      decoded_token = JWT.decode(token,
                                 described_class::RSA_PUBLIC,
                                 true,
                                 { algorithm: described_class::ALGORITHM_TYPE })

      expect(decoded_token).to eq([
                                    {
                                      'sub': '1234567890',
                                      'name': 'John Doe',
                                      'admin': true,
                                      'realm_access': {
                                        'roles': [
                                          'dgi_user'
                                        ]
                                      }
                                    }
                                  ])
    end
  end
end
