# frozen_string_literal: true

require 'json_schemer'
require 'uri'

# data structures built up at class load time then frozen.  This is threadsafe.
module Webhooks
  module Utilities

    module ClassMethods

      # place methods that might be run at class load time here. They mix in as class methods.

      # TODO: All of these methods should be moved out of ClassMethods
      # We assume the subscription parameter has already been through validate_subscription()
      def register_webhook(consumer_id, consumer_name, subscription)
        event = subscription['subscriptions'].first['event']
        api_name = Webhooks::Utilities.event_to_api_name[event]
        wh = fetch_subscription(consumer_id, subscription) || Webhooks::Subscription.new
        wh.api_name = api_name
        wh.consumer_id = consumer_id
        wh.consumer_name = consumer_name
        wh.events = subscription
        wh.save!
        wh
      end

      # todo consider moving this to subscription as it only operates on the one model
      def clean_subscription(api_name, consumer_id, &block)
        raise ArgumentError.new("A block is required!") unless block_given?
        subscription = Subscription.where(api_name: api_name, consumer_id: consumer_id).first
        subscription.with_lock do
          subscription.reload
          block.call(subscription)
        end
      end

      # todo either move to named scope in NotificationAttempt or have this setup the associations too.
      def create_blocked_attempt(url)
        Webhooks::NotificationAttempt.create(callback_url: url, response: {'status' => -1, 'body' => ''})
      end

      def fetch_subscription(consumer_id, subscription)
        event = subscription['subscriptions'].first['event']
        api_name = Webhooks::Utilities.event_to_api_name[event]
        Webhooks::Subscription.where(api_name: api_name, consumer_id: consumer_id)&.first
      end

      # @todo move to named scope in subscription
      def fetch_subscriptions(consumer_id) #api_name?
       Webhooks::Subscription.where(consumer_id: consumer_id).all
      end

      def record_notifications(consumer_id:, consumer_name:, event:, api_guid:, msg:)
        api_name = Webhooks::Utilities.event_to_api_name[event]
        # TODO: replace query with looking against the subscription Greg Bowman
        webhook_urls = Webhooks::Subscription.get_notification_urls(api_name: api_name, consumer_id: consumer_id, event: event)
        subscription = Webhooks::Subscription.where(consumer_id: consumer_id, api_name: api_name).first
        return [] unless webhook_urls.size.positive?
        notifications = []
        webhook_urls.each do |url|
          next if subscription.blocked_callback_urls.include? url
          wh_notify = Webhooks::Notification.new
          wh_notify.api_name = api_name
          wh_notify.consumer_id = consumer_id
          wh_notify.consumer_name = consumer_name
          wh_notify.api_guid = api_guid
          wh_notify.event = event
          wh_notify.callback_url = url
          wh_notify.msg = msg
          wh_notify.webhooks_subscription = subscription
          notifications << wh_notify
        end
        ActiveRecord::Base.transaction { notifications.each(&:save!) }
        notifications
      end
    end
    extend ClassMethods

    # TODO: move methods above here, and refactor calls
    def handle_deleted_urls(urls)
      Rails.logger.info("#{urls.count} URLS have been deleted: #{urls}")
    end

  end
end
