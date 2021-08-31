# frozen_string_literal: true

require 'rails_helper'
require_dependency './lib/webhooks/utilities'

describe Webhooks::Subscription, type: :model do
  let(:consumer_id) { 'f7d83733-a047-413b-9cce-e89269dcb5b1' }
  let(:consumer_name) { 'tester' }
  let(:api_id_invalid) { SecureRandom.uuid }
  let(:fixture_path) { './spec/fixtures/webhooks/subscriptions/' }
  let(:observers) { JSON.parse File.read(fixture_path + 'subscriptions.json') }
  # let(:event) do VBADocuments::Registrations::WEBHOOK_STATUS_CHANGE_EVENT end

  before do
    @subscription = Webhooks::Utilities.register_webhook(consumer_id, consumer_name, observers)
  end

  it 'records the subscription' do
    expect(@subscription.events).to eq(observers)
  end

  it 'records the api name' do
    api_name = Webhooks::Utilities.event_to_api_name[observers['subscriptions'].first['event']]
    expect(@subscription.api_name).to eq(api_name)
  end

  it 'records the consumer name' do
    expect(@subscription.consumer_name).to eq(consumer_name)
  end

  it 'records the consumer id' do
    expect(@subscription.consumer_id).to eq(consumer_id)
  end

  it 'queries for subscriptions correctly' do
    api_name = Webhooks::Utilities.event_to_api_name[observers['subscriptions'].first['event']]
    query_results = Webhooks::Subscription.get_notification_urls(
      api_name: api_name, consumer_id: consumer_id, event: observers['subscriptions'].first['event'])
    observer_urls = []
    observers['subscriptions'].each do |subscription|
      observer_urls << subscription['urls']
    end
    observer_urls = observer_urls.flatten.uniq

    query_results_nil = Webhooks::Subscription.get_notification_urls(
      api_name: api_name, consumer_id: consumer_id, event: observers['subscriptions'].first['event'])

    expect(query_results).to eq(observer_urls)
    expect(query_results_nil).to eq(observer_urls)
  end
end
