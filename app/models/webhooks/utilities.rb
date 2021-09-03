# frozen_string_literal: true

require 'json_schemer'
require 'uri'

# data structures built up at class load time then frozen.  This is threadsafe.
module Webhooks
  module Utilities
    FINAL_ATTEMPT_BLOCKED = {'status' => -1, 'body' => 'URL has been blocked due to excessive failures.'}
    FINAL_ATTEMPT_URL_REMOVED = {'status' => -2, 'body' => 'URL was removed from the registered subscription.'}

    module ClassMethods
      # place methods that might be run at class load time here. They mix in as class methods.

      # TODO: All of these methods should be moved out of ClassMethods Cris?
      # We assume the subscription parameter has already been through validate_subscription()
      def register_webhook(consumer_id, consumer_name, subscription, &block)
        event = subscription['subscriptions'].first['event']
        api_name = Webhooks::Utilities.event_to_api_name[event]
        old_subscription = fetch_subscription(consumer_id, subscription)
        wh = old_subscription || Webhooks::Subscription.new
        wh_copy = wh.clone if old_subscription
        wh.with_lock do
          wh.api_name = api_name
          wh.consumer_id = consumer_id
          wh.consumer_name = consumer_name
          wh.events = subscription
          wh.save!
          if block_given?
            block.call(wh_copy, wh)
          end
        end
        wh
      end

      def fetch_subscription(consumer_id, subscription)
        event = subscription['subscriptions'].first['event']
        api_name = Webhooks::Utilities.event_to_api_name[event]
        Webhooks::Subscription.where(api_name: api_name, consumer_id: consumer_id)&.first
      end

      def record_notifications(consumer_id:, consumer_name:, event:, api_guid:, msg:)
        api_name = Webhooks::Utilities.event_to_api_name[event]
        Webhooks::Subscription.clean_subscription(api_name, consumer_id) do |subscription|
          webhook_urls = subscription.get_notification_urls(event)
          return [] unless webhook_urls.size.positive?

          notifications = []
          webhook_urls.each do |url|
            next if subscription.blocked_callback_urls.include? url

            wh_notify = Webhooks::Notification.new(
                api_name: api_name, consumer_id: consumer_id, consumer_name: consumer_name,
                api_guid: api_guid, event: event, callback_url: url, msg: msg)
            wh_notify.webhooks_subscription = subscription
            notifications << wh_notify
          end
          ActiveRecord::Base.transaction { notifications.each(&:save!) }
          notifications
        end
      end
    end
    extend ClassMethods

    def record_attempt(notifications:, success:, response:, max_retries:)
      callback_url = notifications.first.callback_url
      attempt = Webhooks::NotificationAttempt.new(callback_url: callback_url, success: success, response: response)
      attempt.save!
      notifications.each do |n|
        Webhooks::NotificationAttemptAssoc.new(
            webhooks_notification_id: n.id, webhooks_notification_attempt_id: attempt.id).save!

        # set the final attempt id if appropriate and turn off processing for each notification
        final_attempt = success || n.webhooks_notification_attempts.count >= max_retries || max_retries < 0
        n.final_attempt_id = attempt.id if final_attempt
        n.processing = nil
        n.save!
      end
      attempt
    end

    # rubocop:disable Metrics/MethodLength
    def record_attempt_metadata(url, success, response, locked_sub)
      metadata = locked_sub.metadata
      metadata[url] ||= {}

      if success
        metadata[url][Subscription::FAILURE_KEY] = {}
      else
        metadata[url][Subscription::FAILURE_KEY] ||= {}
        if response.key? NotificationAttempt::RESPONSE_EXCEPTION
          status_code =
              response[NotificationAttempt::RESPONSE_EXCEPTION][NotificationAttempt::RESPONSE_EXCEPTION_TYPE]
        else
          status_code = response[NotificationAttempt::RESPONSE_STATUS]
        end
        metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS] ||= {}
        metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS]['total'] ||= 0
        metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS]['total'] += 1
        metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS][status_code.to_s] ||= 0
        metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS][status_code.to_s] += 1

        # calculate next time via block and record
        failure_block = Utilities.api_name_to_failure_block[locked_sub.api_name]
        next_time = 1.hour.from_now
        begin
          next_time = failure_block
                          .call(metadata[url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS])
        rescue => e
          Rails.logger.error("For #{locked_sub.api_name} the webhook failure block failed to execute.", e)
        end
        metadata[url][Subscription::FAILURE_KEY][Subscription::RUN_AFTER_KEY] = next_time.to_i
      end
      locked_sub.metadata = metadata
      locked_sub.save!
    end

    # rubocop:enable Metrics/MethodLength
  end
end
