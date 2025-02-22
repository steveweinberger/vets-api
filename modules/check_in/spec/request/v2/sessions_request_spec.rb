# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V2::SessionsController', type: :request do
  let(:id) { 'd602d9eb-9a31-484f-9637-13ab0b507e0d' }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    allow(Flipper).to receive(:enabled?)
      .with('check_in_experience_multiple_appointment_support').and_return(true)

    Rails.cache.clear
  end

  describe 'GET `show`' do
    context 'when invalid uuid' do
      let(:invalid_uuid) { 'invalid_uuid' }
      let(:resp) do
        {
          'error' => true,
          'message' => 'Invalid last4 or last name!'
        }
      end

      it 'returns an error response' do
        get "/check_in/v2/sessions/#{invalid_uuid}"

        # Even though this is unauthorized, we want to return a 200 back.
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(resp)
      end
    end

    context 'when token not present in session cookie or cache' do
      let(:uuid) { Faker::Internet.uuid }
      let(:resp) do
        {
          'permissions' => 'read.none',
          'status' => 'success',
          'uuid' => uuid
        }
      end

      it 'returns read.none permissions' do
        get check_in.v2_session_path(uuid)

        # Even though this is unauthorized, we want to return a 200 back.
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(resp)
      end
    end

    context 'when token present' do
      let(:uuid) { Faker::Internet.uuid }
      let(:key) { "check_in_lorota_v2_#{uuid}_read.full" }
      let(:resp) do
        {
          'permissions' => 'read.full',
          'status' => 'success',
          'uuid' => uuid
        }
      end

      it 'returns read.full permissions' do
        allow_any_instance_of(CheckIn::V2::Session).to receive(:redis_session_prefix).and_return('check_in_lorota_v2')
        allow_any_instance_of(CheckIn::V2::Session).to receive(:jwt).and_return('jwt-123-1bc')

        Rails.cache.write(key, 'jwt-123-1bc', namespace: 'check-in-lorota-v2-cache')

        get "/check_in/v2/sessions/#{uuid}"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(resp)
      end
    end
  end

  describe 'POST `create`' do
    let(:uuid) { Faker::Internet.uuid }
    let(:resp) do
      {
        'permissions' => 'read.full',
        'status' => 'success',
        'uuid' => uuid
      }
    end
    let(:session_params) do
      {
        params: {
          session: {
            uuid: uuid,
            last4: '5555',
            last_name: 'Johnson'
          }
        }
      }
    end
    let(:key) { "check_in_lorota_v2_#{uuid}_read.full" }

    context 'when invalid params' do
      let(:invalid_uuid) { 'invalid_uuid' }
      let(:resp) do
        {
          'error' => true,
          'message' => 'Invalid last4 or last name!'
        }
      end
      let(:session_params) do
        {
          params: {
            session: {
              uuid: invalid_uuid,
              last4: '555',
              last_name: ''
            }
          }
        }
      end

      it 'returns an error response' do
        post '/check_in/v2/sessions', session_params

        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq(resp)
      end
    end

    context 'when JWT token and Redis entries are present' do
      it 'returns a success response' do
        allow_any_instance_of(CheckIn::V2::Session).to receive(:redis_session_prefix).and_return('check_in_lorota_v2')
        allow_any_instance_of(CheckIn::V2::Session).to receive(:jwt).and_return('jwt-123-1bc')

        Rails.cache.write(key, 'jwt-123-1bc', namespace: 'check-in-lorota-v2-cache')

        post '/check_in/v2/sessions', session_params

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(resp)
      end
    end

    context 'when JWT token and Redis entries are absent' do
      let(:service_resp) do
        {
          'permission_data' => { 'permissions' => 'read.full', 'uuid' => uuid, 'status' => 'success' },
          'jwt' => 'jwt-123-abc'
        }
      end

      before do
        allow_any_instance_of(::V2::Lorota::Service).to receive(:token).and_return(service_resp)
        expect_any_instance_of(::V2::Lorota::Service).to receive(:token).once
      end

      it 'returns a success response' do
        post '/check_in/v2/sessions', session_params

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(service_resp[:permission_data])
      end
    end
  end
end
