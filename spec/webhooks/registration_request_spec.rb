# frozen_string_literal: true

require 'rails_helper'
require './lib/webhooks/utilities.rb'

RSpec.describe 'Webhook registration tests', type: :request, retry: 3 do
  load('./config/routes.rb')

  let(:dev_headers) do
    {
      'X-Consumer-ID': '59ac8ab0-1f28-43bd-8099-23adb561815d',
      'X-Consumer-Username': 'Development'
    }
  end
  let(:fixture_path) { './spec/fixtures/webhooks/subscriptions/' }

  describe '#subscribe /webhooks/register' do
    context 'register' do
      before do
        s3_client = instance_double(Aws::S3::Resource)
        allow(Aws::S3::Resource).to receive(:new).and_return(s3_client)
        s3_bucket = instance_double(Aws::S3::Bucket)
        s3_object = instance_double(Aws::S3::Object)
        allow(s3_client).to receive(:bucket).and_return(s3_bucket)
        allow(s3_bucket).to receive(:object).and_return(s3_object)
        allow(s3_object).to receive(:presigned_url).and_return(+'https://fake.s3.url/foo/guid')
      end

      %i[file text].each do |multipart_fashion|
        it "accepts valid #{multipart_fashion} subscription. Returns api_name and current_subscription" do
          webhook_json = File.read(fixture_path + 'subscriptions.json')
          webhook = Rack::Test::UploadedFile.new("#{fixture_path}subscriptions.json", 'application/json')
          webhook = webhook_json if multipart_fashion == :text
          post '/v1/webhooks/register',
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
                        Rack::Test::UploadedFile.new("#{fixture_path}invalid_subscription_#{test_case}.json",
                                                     'application/json')
                      else
                        File.read("#{fixture_path}invalid_subscription_#{test_case}.json")
                      end

            post '/v1/webhooks/register',
                 params: {
                   'webhook': webhook
                 },
                 headers: dev_headers
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      it 'returns error if spanning multiple api names' do
        webhook = File.read("#{fixture_path}subscriptions_multiple.json")

        post '/v1/webhooks/register',
             params: {
               'webhook': webhook
             },
             headers: dev_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
