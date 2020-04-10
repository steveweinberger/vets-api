# frozen_string_literal: true

FactoryBot.define do
  factory :vet360_validation_address, class: 'Vet360::Models::ValidationAddress' do
    address_pou { Vet360::Models::Address::RESIDENCE }

    trait :multiple_matches do
      address_type { Vet360::Models::Address::INTERNATIONAL }
      address_line1 { '898 W Broaadway' }
      city { 'Vancouver' }
      province { 'BC' }
      international_postal_code { 'V5Z 1J8' }
      country_code_iso3 { 'CAN' }
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
