# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/iam_session_helper'
require_relative '../../support/matchers/json_schema_matcher'

RSpec.describe 'appointments', type: :request do
  include JsonSchemaMatchers

  before do
    allow_any_instance_of(IAMUser).to receive(:icn).and_return('24811694708759028')
    iam_sign_in(build(:iam_user))
    allow_any_instance_of(VAOS::UserService).to receive(:session).and_return('stubbed_token')
  end

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  describe 'GET /mobile/v1/appointments' do
    before do
      Timecop.freeze(Time.zone.parse('2020-11-01T10:30:00Z'))
    end

    after { Timecop.return }

    context 'with valid params' do
      let(:params) { { page: { number: 1, size: 10 }, useCache: true } }

      context 'with a user has mixed upcoming appointments' do
        before do
          VCR.use_cassette('appointments/get_facilities', match_requests_on: %i[method uri]) do
            VCR.use_cassette('appointments/get_cc_appointments_default', match_requests_on: %i[method uri]) do
              VCR.use_cassette('appointments/get_appointments_default', match_requests_on: %i[method uri]) do
                get '/mobile/v1/appointments', headers: iam_headers, params: params
              end
            end
          end
        end

        let(:first_appointment) { response.parsed_body['data'].first['attributes'] }
        let(:last_appointment) { response.parsed_body['data'].last['attributes'] }

        it 'returns an ok response' do
          expect(response).to have_http_status(:ok)
        end

        it 'matches the expected schema' do
          expect(response.body).to match_json_schema('appointments')
        end

        it 'sorts the appointments by startDateUtc ascending' do
          expect(first_appointment['startDateUtc']).to be < last_appointment['startDateUtc']
        end

        it 'includes the expected properties for a patient cancelled VA appointment' do
          va_appointment_patient_cancelled = response.parsed_body['data'].filter do |a|
                                               a['attributes']['appointmentType'] == 'VA'
                                             end                                             [1]
          expect(va_appointment_patient_cancelled['attributes']['status']).to eq('CANCELLED BY PATIENT')
        end

        it 'includes the expected properties for a clinic cancelled VA appointment' do
          va_appointment_patient_cancelled = response.parsed_body['data'].filter do |a|
                                               a['attributes']['appointmentType'] == 'VA'
                                             end                                             [2]
          expect(va_appointment_patient_cancelled['attributes']['status']).to eq('CANCELLED BY CLINIC')
        end
      end
    end
  end
end
