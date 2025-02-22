# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'maintenance windows', type: :request do
  include JsonSchemaMatchers
  describe 'GET /v0/maintenance_windows' do
    context 'when no maintenance windows are active' do
      before { get '/mobile/v0/maintenance_windows', headers: { 'X-Key-Inflection' => 'camel' } }

      it 'matches the expected schema' do
        expect(response.body).to match_json_schema('maintenance_windows')
      end

      it 'returns an empty array of affected services' do
        expect(response.parsed_body['data']).to eq([])
      end
    end

    context 'when a maintenance with many dependent services is active' do
      before do
        Timecop.freeze('2021-05-25T23:33:39Z')
        FactoryBot.create(:mobile_maintenance_evss)
        FactoryBot.create(:mobile_maintenance_mpi)
        get '/mobile/v0/maintenance_windows', headers: { 'X-Key-Inflection' => 'camel' }
      end

      after { Timecop.return }

      it 'matches the expected schema' do
        expect(response.body).to match_json_schema('maintenance_windows')
      end

      it 'returns an array of the affected services' do
        expect(response.parsed_body['data']).to eq(
          [
            {
              'id' => '321e9dcf-2578-5956-9baa-295735d97c3c',
              'type' => 'maintenance_window',
              'attributes' => {
                'service' => 'claims',
                'startTime' => '2021-05-25T21:33:39.000Z',
                'endTime' => '2021-05-26T01:45:00.000Z'
              }
            },
            {
              'id' => '14ad3ba9-7ec8-51b8-bbb3-dc20e6655b26',
              'type' => 'maintenance_window',
              'attributes' => {
                'service' => 'direct_deposit_benefits',
                'startTime' => '2021-05-25T21:33:39.000Z',
                'endTime' => '2021-05-26T01:45:00.000Z'
              }
            },
            {
              'id' => '858b59df-4cef-5f34-91a4-57edd382e4e5',
              'type' => 'maintenance_window',
              'attributes' => {
                'service' => 'disability_rating',
                'startTime' => '2021-05-25T21:33:39.000Z',
                'endTime' => '2021-05-26T01:45:00.000Z'
              }
            },
            {
              'id' => 'cac05630-8879-594c-8655-1a6ff582dc5d',
              'type' => 'maintenance_window',
              'attributes' => {
                'service' => 'letters_and_documents',
                'startTime' => '2021-05-25T21:33:39.000Z',
                'endTime' => '2021-05-26T01:45:00.000Z'
              }
            }
          ]
        )
      end
    end
  end
end
