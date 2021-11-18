# frozen_string_literal: true

FactoryBot.define do
  factory :mobile_vaccine, class: 'Mobile::V0::Vaccine' do
    cvx_code { 1 }
    group_name { 'COVID-19' }
    manufacturer { 'Moderna' }
  end
end
