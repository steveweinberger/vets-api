# frozen_string_literal: true

# require './spec/lib/webhooks/utilities_helper'
require 'rails_helper'
require_relative 'job_tracking'
require './lib/webhooks/utilities'
require_relative 'registrations'

RSpec.describe Webhooks::CallbackUrlJob, type: :job do
  let(:faraday_response) { instance_double('Faraday::Response') }
  let(:consumer_id) { 'f7d83733-a047-413b-9cce-e89269dcb5b1' }
  let(:consumer_name) { 'tester' }
  let(:api_guid) { SecureRandom.uuid }
  let(:msg) { {'msg' => 'the message'} }
  let(:observers_json) do
    {
        'subscriptions' => [
            {
                'event' => Registrations::TEST_EVENT,
                'urls' => [
                    'https://i/am/listening',
                    'https://i/am/also/listening'
                ]
            }
        ]
    }
  end
  let(:params) do
    {consumer_id: consumer_id, consumer_name: consumer_name,
     event: Registrations::TEST_EVENT, api_guid: api_guid, msg: msg}
  end

  let(:urls) { observers_json['subscriptions'].first['urls'] }

  before do
    @subscription = Webhooks::Utilities.register_webhook(consumer_id, consumer_name, observers_json)

    @notifications = Webhooks::Utilities.record_notifications(params)

    @notification_by_url = lambda do |url, notifications = @notifications|
      notifications.select do |n|
        n.callback_url.eql?(url)
      end.map(&:id)
    end
  end

  def mock_faraday(status, body, success)
    allow(Faraday).to receive(:post).and_return(faraday_response)
    allow(faraday_response).to receive(:status).and_return(status)
    allow(faraday_response).to receive(:body).and_return(body)
    allow(faraday_response).to receive(:success?).and_return(success)
  end

  it 'notifies the callback urls' do
    mock_faraday(200, '', true)
    urls.each do |url|
      described_class.new.perform(url, @notification_by_url.call(url), Registrations::MAX_RETRIES)
    end
    @notifications.each do |notification_row|
      notification_row.reload
      expect(notification_row.final_attempt_id).to be_an(Integer)
      attempt = notification_row.final_attempt
      expect(attempt.success).to be true
      expect(attempt.response['status']).to be 200
    end
  end

  it 'does not notify on urls that have been removed from subscription' do
    urls.inspect # instantiate urls in rspec
    observers_json['subscriptions'].first['urls'] = [observers_json['subscriptions'].first['urls'].first]
    @subscription = Webhooks::Utilities.register_webhook(consumer_id, consumer_name, observers_json)
    mock_faraday(200, '', true)
    urls.each do |url|
      described_class.new.perform(url, @notification_by_url.call(url), Registrations::MAX_RETRIES)
    end
    @notifications.each(&:reload)
    notif_success = @notifications.select do |n|
      n.callback_url.eql?(urls.first)
    end.first
    notif_failure = @notifications.select do |n|
      n.callback_url.eql?(urls.last)
    end.first
    expect(notif_success.final_attempt.success).to be true
    expect(notif_failure.final_attempt.success).to be false
    expect(notif_failure.final_attempt.response['status']).
        to be Webhooks::Utilities::FINAL_ATTEMPT_URL_REMOVED['status']
  end

  context 'maintenance' do

    before do
      urls = @subscription.get_notification_urls(Registrations::TEST_EVENT)
      @subscription.set_maintenance(urls.first, true)
      @subscription.set_maintenance(urls.last, false)
      @subscription.save!
      @url_in_maintenance = urls.first
      @url_not_in_maintenance = urls.last
    end

    it 'does not notify when under maintenance, does for those that are not' do
      described_class.new.perform(@url_in_maintenance, @notification_by_url.call(@url_in_maintenance),
                                  Registrations::MAX_RETRIES)
      described_class.new.perform(@url_not_in_maintenance, @notification_by_url.call(@url_not_in_maintenance),
                                  Registrations::MAX_RETRIES)
      under_maintenance = Webhooks::Notification.find_by(id: @notification_by_url.call(urls.first))
      not_under_maintenance = Webhooks::Notification.find_by(id: @notification_by_url.call(urls.last))
      expect(under_maintenance.webhooks_notification_attempts.count).to be 0
      expect(not_under_maintenance.webhooks_notification_attempts.count).to be 1
    end

    def check_notifications_for_maintenance(count, record_notif_call_count)
      @notification_by_url.call(@url_in_maintenance).each do |notif_id|
        notif = Webhooks::Notification.find_by(id: notif_id)
        expect(notif.webhooks_notification_attempts.count).to be count
      end
      ids = @notification_by_url.call(@url_in_maintenance)
      expect(ids.length).to be record_notif_call_count
    end

    it 'sends batches of notifications to urls that return to service from maintenance' do
      described_class.new.perform(@url_in_maintenance, @notification_by_url.call(@url_in_maintenance),
                                  Registrations::MAX_RETRIES)
      check_notifications_for_maintenance(0, 1)
      @notifications << Webhooks::Utilities.record_notifications(params)
      @notifications.flatten!
      described_class.new.perform(@url_in_maintenance, @notification_by_url.call(@url_in_maintenance),
                                  Registrations::MAX_RETRIES)
      check_notifications_for_maintenance(0, 2)
      @subscription.set_maintenance(@url_in_maintenance, false)
      @subscription.save!
      @notifications << Webhooks::Utilities.record_notifications(params)
      @notifications.flatten!
      # not in maintenance anymore!
      described_class.new.perform(@url_in_maintenance, @notification_by_url.call(@url_in_maintenance),
                                  Registrations::MAX_RETRIES)
      check_notifications_for_maintenance(1, 3)
      associations = Webhooks::NotificationAttemptAssoc.
          where('webhooks_notification_id in (?)', @notification_by_url.call(@url_in_maintenance)).count
      expect(associations).to be 3
    end
  end

  context 'failures' do
    it 'records failure attempts from a responsive callback url' do
      mock_faraday(400, '', false)
      urls.each do |url|
        described_class.new.perform(url, @notification_by_url.call(url), Registrations::MAX_RETRIES)
      end
      @notifications.each do |notification_row|
        notification_row.reload
        expect(notification_row.final_attempt_id).to be nil
        expect(notification_row.final_attempt).to be nil
        wna = notification_row.webhooks_notification_attempts
        expect(wna.count).to be 1
        attempt = wna.first
        expect(attempt.success).to be false
        expect(attempt.response['status']).to be 400
      end
    end

    it 'the final attempt id is set if we fail max retries' do
      # , focus: true do
      mock_faraday(400, '', false)
      max_retries = Registrations::MAX_RETRIES
      urls.each do |url|
        (max_retries).times do
          described_class.new.perform(url, @notification_by_url.call(url), max_retries)
        end
      end
      @notifications.each do |notification_row|
        notification_row.reload
        expect(notification_row.final_attempt_id).to be_an(Integer)
        expect(notification_row.webhooks_notification_attempts.count).to be max_retries
        attempt = notification_row.final_attempt
        expect(attempt.success).to be false
        expect(attempt.response['status']).to be 400
      end
    end

    it 'the subscription has blocked callback urls with too many failures' do
      failure_limit = Registrations::MAX_RETRIES - 1
      Thread.current['failure_limit'] = failure_limit
      max_retries = Registrations::MAX_RETRIES
      mock_faraday(400, '', false)
      blocked_urls = @subscription.blocked_callback_urls
      expect(blocked_urls.empty?).to be true
      urls.each do |url|
        (failure_limit + 1).times do
          described_class.new.perform(url, @notification_by_url.call(url), max_retries)
        end
      end
      @subscription.reload
      blocked_urls = @subscription.blocked_callback_urls
      expect(!blocked_urls.empty?).to be true
      expect((blocked_urls - urls).empty?).to be true
      expect((urls - blocked_urls).empty?).to be true
      @notifications.each do |notification_row|
        notification_row.reload
        expect(notification_row.final_attempt_id).to be_an(Integer)
        attempt = notification_row.final_attempt
        expect(attempt.success).to be false
        expect(attempt.response['status']).to be -1
      end
      Thread.current['failure_limit'] = nil
    end


    it 'records failure attempts from an unresponsive callback url' do
      errors = [Faraday::ClientError.new('busted'), StandardError.new('busted')]
      errors.each do |error|
        # standard error forces exercise of last exception block
        allow(Faraday).to receive(:post).and_raise(error)
        urls.each do |url|
          described_class.new.perform(url, @notification_by_url.call(url), Registrations::MAX_RETRIES)
        end
        @notifications.each do |notification_row|
          notification_row.reload
          expect(notification_row.final_attempt_id).to be nil
          wna = notification_row.webhooks_notification_attempts
          wna.each do |attempt|
            expect(attempt.success).to be false
            expect(attempt.response['exception']['message']).to eql('busted')
            expect(errors.map { |e| e.class.to_s }.include? attempt.response['exception']['type'])
          end
        end
      end
    end
  end
end
