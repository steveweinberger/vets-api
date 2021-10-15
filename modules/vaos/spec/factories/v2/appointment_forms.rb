# frozen_string_literal: true

FactoryBot.define do
  factory :appointment_form_v2, class: 'VAOS::V2::AppointmentForm' do
    transient do
      user { build(:user, :vaos) }
    end

    initialize_with { new(user, attributes) }

    trait :eligible do
      kind { 'cc' }
      status { 'proposed' }
      location_id { '983' }
      practitioner_ids { [{ system: 'deprecated', value: 'deprecated' }] }
      preferred_language { 'English' }
      reason { 'deprecated' }

      practitioners do
        [
          {
            'identifier' => [
              {
                'system': 'test',
                'value': 'test'
              },
              {
                'system': 'test2',
                'value': 'test2'
              }
            ],
            'name': {
              'family': 'test',
              'given': 'test'
            },
            'first_name': 'deprecated',
            'last_name': 'deprecated',
            'practice_name': 'deprecated'
          }
        ]
      end

      reason_code do
        {
          'coding' => [
            {
              'system': 'test',
              'code': 'test',
              'display': 'test'
            },
            {
              'system': 'test2',
              'code': 'test2',
              'display': 'test2'
            }
          ],
          'text': 'test'
        }
      end

      slot do
        {
          'id': 'test',
          'start' => DateTime.new(2021, 0o6, 15, 12, 0o0, 0).iso8601(3),
          'end' => DateTime.new(2021, 0o6, 15, 23, 59, 0).iso8601(3)
        }
      end
      priority { 2 }
      minutes_duration { 10 }
      preferred_times_for_phone_call do
        %w[Morning Evening]
      end

      preferred_location do
        {
          'city': 'test',
          'state': 'test'
        }
      end

      cancellable { true }
      patient_instruction { 'test' }
      telehealth do
        {
          'url': 'test',
          'atlas': {
            'site_code': 'test',
            'confirmation_code': 'test',
            'address': {
              'street_address': 'test',
              'city': 'test',
              'state': 'test',
              'zip': 'test',
              'country': 'test',
              'latitude': 10,
              'longitude': 10,
              'additional_details': 'test'
            }
          },
          'group': true,
          'vvs_kind': 'test'
        }
      end

      extension do
        {
          'desired_date': DateTime.new(2021, 0o6, 15, 23, 59, 0).iso8601(3)
        }
      end

      cancellation_reason do
        {
          'system': 'test',
          'code': 'test',
          'display': 'test'
        }
      end

      cancelation_reason do
        {
          'coding' => [
            {
              'system': 'test',
              'code': 'test',
              'display': 'test'
            },
            {
              'system': 'test2',
              'code': 'test2',
              'display': 'test2'
            }
          ],
          'text': 'test'
        }
      end

      contact do
        {
          'telecom' => [
            {
              'type': 'phone',
              'value': '2125688889'
            },
            {
              'type': 'email',
              'value': 'judymorisooooooooooooon@gmail.com'
            }
          ]
        }
      end

      service_type { 'CCPOD' }
      requested_periods do
        [
          {
            'start': DateTime.new(2021, 0o6, 15, 12, 0o0, 0).iso8601(3),
            'end': DateTime.new(2021, 0o6, 15, 23, 59, 0).iso8601(3)
          }
        ]
      end
    end

    trait :with_empty_slot_hash do
      eligible
      slot { {} }
    end
  end
end
