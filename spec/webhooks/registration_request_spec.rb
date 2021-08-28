# frozen_string_literal: true

require 'rails_helper'
require './lib/webhooks/utilities.rb'

RSpec.describe 'Webhook registration tests', type: :request, retry: 3 do
  Settings.webhooks.enabled = true
  load('./config/routes.rb')

  let(:dev_headers) do
    {
      'X-Consumer-ID': '59ac8ab0-1f28-43bd-8099-23adb561815d',
      'X-Consumer-Username': 'Development'
    }
  end
  let(:subscription_fixture_path) { './spec/fixtures/webhooks/subscriptions/' }
  let(:maintenance_fixture_path) { './spec/fixtures/webhooks/maintenance/' }

  describe '#subscribe /webhooks/register' do
    context 'register' do
      %i[file text].each do |multipart_fashion|
        it "accepts valid #{multipart_fashion} subscription. Returns api_name and current_subscription" do
          webhook_json = File.read(subscription_fixture_path + 'subscriptions.json')
          webhook = Rack::Test::UploadedFile.new("#{subscription_fixture_path}subscriptions.json", 'application/json')
          webhook = webhook_json if multipart_fashion == :text
          post v1_webhooks_register_path,
               params: {
                 'webhook': webhook
               },
               headers: dev_headers
          expect(response).to have_http_status(:accepted)
          json = JSON.parse(response.body)
          expect(json['data']['attributes']).to have_key('api_name')
          expect(json['data']['attributes']['current_subscription']).to eq(JSON.parse(webhook_json))
        end
      end

      %i[missing_event bad_URL unknown_event not_https duplicate_events not_JSON empty_array].each do |test_case|
        %i[file text].each do |multipart_fashion|
          it "returns error with invalid #{test_case} registration sent as #{multipart_fashion}" do
            webhook = if multipart_fashion == :file
                        Rack::Test::UploadedFile.new("#{subscription_fixture_path}invalid_subscription_#{test_case}.json",
                                                     'application/json')
                      else
                        File.read("#{subscription_fixture_path}invalid_subscription_#{test_case}.json")
                      end

            post v1_webhooks_register_path,
                 params: {
                   'webhook': webhook
                 },
                 headers: dev_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      it 'returns error if spanning multiple api names' do
        webhook = File.read("#{subscription_fixture_path}subscriptions_multiple.json")

        post v1_webhooks_register_path,
             params: {
               'webhook': webhook
             },
             headers: dev_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#maintenance /webhooks/maintenance' do
    context 'maintenance' do
      before do
        subscription = JSON.parse(File.read(subscription_fixture_path + 'subscriptions.json'))
        Webhooks::Utilities.register_webhook(dev_headers[:'X-Consumer-ID'],
                                             dev_headers[:'X-Consumer-Username'],
                                             subscription)
      end

      %i[file text].each do |multipart_fashion|
        it "accepts valid #{multipart_fashion} maintenance and updates the metadata" do
          maint_json = File.read(maintenance_fixture_path + 'maintenance.json')
          maint = Rack::Test::UploadedFile.new("#{maintenance_fixture_path}maintenance.json", 'application/json')
          maint = maint_json if multipart_fashion == :text
          post v1_webhooks_maintenance_path,
               params: {
                 'webhook_maintenance': maint
               },
               headers: dev_headers
          expect(response).to have_http_status(:no_content)
        end
      end

      %i[missing_api_name bad_URL unknown_api_name empty_array].each do |test_case|
        %i[file text].each do |multipart_fashion|
          it "returns error with invalid #{test_case} maintenance sent as #{multipart_fashion}" do
            maint = if multipart_fashion == :file
                      Rack::Test::UploadedFile.new("#{maintenance_fixture_path}invalid_maintenance_#{test_case}.json",
                                                   'application/json')
                    else
                      File.read("#{maintenance_fixture_path}invalid_maintenance_#{test_case}.json")
                    end

            post v1_webhooks_maintenance_path,
                 params: {
                   'webhook_maintenance': maint
                 },
                 headers: dev_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
