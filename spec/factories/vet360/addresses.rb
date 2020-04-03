# frozen_string_literal: true

FactoryBot.define do
  factory :vet360_address, class: 'Vet360::Models::Address' do
    trait :mailing do
      address_pou { Vet360::Models::Address::CORRESPONDENCE }
      address_line1 { '1515 Broadway' }
    end

    trait :domestic do
      address_type { Vet360::Models::Address::DOMESTIC }
    end

    trait :international do
      address_type { Vet360::Models::Address::INTERNATIONAL }
      international_postal_code { '100-0001' }
      state_code { nil }
      zip_code { nil }
    end

    trait :military_overseas do
      address_type { Vet360::Models::Address::MILITARY }
    end

    trait :multiple_matches do
      address_line1 { '37 1st st' }
      city { 'Brooklyn' }
      state_code { 'NY' }
      zip_code { '11249' }
    end

    trait :override do
      address_pou { Vet360::Models::Address::RESIDENCE }
      id { 15035 }
      address_line1 { 'abc' }
      city { 'tokyo' }
      province { 'province' }
      international_postal_code { '12345' }
      vet360_id { '1' }
      source_system_user { '1234' }
      source_date { Time.now.utc.iso8601 }
      effective_start_date { Time.now.utc.iso8601 }
    end
  end
end
