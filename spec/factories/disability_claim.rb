# frozen_string_literal: true

FactoryBot.define do
  factory :disability_claim, class: 'SavedClaim::DisabilityClaim' do
    form_id { '21-526EZ' }

    form do
      {
        privacyAgreementAccepted: true,
        veteranFullName: {
          first: 'Test',
          last: 'User'
        },
        gender: 'F',
        email: 'foo@foo.com',
        veteranDateOfBirth: '1989-12-13',
        veteranSocialSecurityNumber: '111223333',
        veteranAddress: {
          country: 'USA',
          state: 'CA',
          postalCode: '90210',
          street: '123 Main St',
          city: 'Anytown'
        }
      }.to_json
    end
  end
end
