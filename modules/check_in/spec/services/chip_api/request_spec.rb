# frozen_string_literal: true

require 'rails_helper'

describe ChipApi::Request do
  subject { described_class }

  describe '.build' do
    it 'returns an instance of Request' do
      expect(subject.build).to be_an_instance_of(ChipApi::Request)
    end
  end

  describe '#get' do
    let(:opts) do
      {
        path: '/dev/appointments/d602d9eb-9a31-484f-9637-13ab0b507e0d',
        access_token: 'abc123'
      }
    end
    let(:conn) { double('Faraday::Connection') }

    it 'connection is called with get' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).with(anything).and_return(anything)

      expect_any_instance_of(Faraday::Connection).to receive(:get)
        .with('/dev/appointments/d602d9eb-9a31-484f-9637-13ab0b507e0d').once

      subject.build.get(opts)
    end
  end

  describe '#post' do
    let(:opts) do
      {
        path: '/dev/actions/check-in/d602d9eb-9a31-484f-9637-13ab0b507e0d',
        access_token: 'abc123'
      }
    end

    it 'connection is called with post' do
      allow_any_instance_of(Faraday::Connection).to receive(:post).with(anything).and_return(anything)

      expect_any_instance_of(Faraday::Connection).to receive(:post)
        .with('/dev/actions/check-in/d602d9eb-9a31-484f-9637-13ab0b507e0d').once

      subject.build.post(opts)
    end
  end

  describe '#connection' do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }
    let(:opts) do
      {
        path: '/dev/appointments/d602d9eb-9a31-484f-9637-13ab0b507e0d',
        access_token: 'abc123'
      }
    end

    after do
      Faraday.default_connection = nil
    end

    it 'creates a new instance just once' do
      allow(Faraday).to receive(:new).and_return(conn)

      expect(Faraday).to receive(:new).once

      subject.build.connection
    end

    it 'GET has headers' do
      stubs.get('/dev/appointments/d602d9eb-9a31-484f-9637-13ab0b507e0d') do |_env|
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"check-in": "foo"}'
        ]
      end

      allow_any_instance_of(subject).to receive(:connection).and_return(conn)

      expect(subject.build.get(opts).env.request_headers)
        .to eq({ 'x-apigw-api-id' => '2dcdrrn5zc', 'Authorization' => 'Bearer abc123' })

      stubs.verify_stubbed_calls
    end

    context 'with access_token' do
      let(:opts) do
        {
          path: '/dev/actions/check-in/d602d9eb-9a31-484f-9637-13ab0b507e0d',
          access_token: 'abc123'
        }
      end

      it 'POST has bearer headers' do
        stubs.post('/dev/actions/check-in/d602d9eb-9a31-484f-9637-13ab0b507e0d') do |_env|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"status": "success"}'
          ]
        end

        allow_any_instance_of(subject).to receive(:connection).and_return(conn)

        expect(subject.build.post(opts).env.request_headers)
          .to eq({ 'x-apigw-api-id' => '2dcdrrn5zc', 'Authorization' => 'Bearer abc123', 'Content-Length' => '0' })

        stubs.verify_stubbed_calls
      end
    end

    context 'with claims_token' do
      let(:opts) do
        {
          path: '/dev/token',
          claims_token: 'efgh5678'
        }
      end

      it 'POST has basic headers' do
        stubs.post('/dev/token') do |_env|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"token": "7896"}'
          ]
        end

        allow_any_instance_of(subject).to receive(:connection).and_return(conn)

        expect(subject.build.post(opts).env.request_headers)
          .to eq({ 'x-apigw-api-id' => '2dcdrrn5zc', 'Authorization' => 'Basic efgh5678', 'Content-Length' => '0' })

        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#headers' do
    it 'has default headers' do
      expect(subject.build.headers).to eq({ 'x-apigw-api-id' => '2dcdrrn5zc' })
    end
  end

  describe '#settings' do
    it 'has a url' do
      expect(subject.build.url).to eq('https://vpce-06399548ef94bdb41-lk4qp2nd.execute-api.us-gov-west-1.vpce.amazonaws.com')
    end

    it 'has a service_name' do
      expect(subject.build.service_name).to eq('CHIP-API')
    end

    it 'has a tmp_api_id' do
      expect(subject.build.tmp_api_id).to eq('2dcdrrn5zc')
    end
  end
end
