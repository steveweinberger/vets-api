# frozen_string_literal: true

FactoryBot.define do
  factory :vet360_validation_address, class: 'Vet360::Models::ValidationAddress' do
    address_pou { Vet360::Models::Address::RESIDENCE }
    address_type { Vet360::Models::Address::INTERNATIONAL }
    country_code_iso3 { 'JPN' }

    trait :multiple_matches do
      address_line1 { 'abc' }
      city { 'tokyo' }
      province { 'province' }
      international_postal_code { '12345' }
    end

    trait :override do
      address_pou { Vet360::Models::Address::CORRESPONDENCE }
      address_line1 { '1494 Martin Luther King Rd' }
      address_line2 { 'c/o foo' }
      city { 'Fulton' }
      state_code { 'MS' }
      zip_code { '38843' }
    end
  end
end
