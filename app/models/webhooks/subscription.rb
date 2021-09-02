# frozen_string_literal: true

module Webhooks
  class Subscription < ApplicationRecord
    self.table_name = 'webhooks_subscriptions'

    has_many :webhooks_notifications, class_name: 'Webhooks::Notification', dependent: :destroy

    # rubocop:disable Rails/RelativeDateConstant
    BLOCKED_CALLBACK = 100.years.from_now
    # rubocop:enable Rails/RelativeDateConstant

    FAILURE_KEY = 'failure_hash'
    MAINTENANCE_KEY = 'maintenance_hash'
    UNDER_MAINT_KEY = 'under_maintenance'
    RUN_AFTER_KEY = 'run_after_epoch'

    def self.clean_subscription(api_name, consumer_id, &block)
      raise ArgumentError, 'A block is required!' unless block_given?

      subscription = Subscription.where(api_name: api_name, consumer_id: consumer_id).first
      raise Common::Exceptions::RecordNotFound, consumer_id unless subscription

      subscription.with_lock do
        subscription.reload
        block.call(subscription)
      end
    end

    def self.list_subscriptions(consumer_id)
      Subscription.where(consumer_id: consumer_id).all
    end

    # rubocop:disable Style/RescueModifier
    def blocked_callback_urls
      metadata = self.metadata
      ret = []
      metadata.each_key do |url|
        run_after = metadata[url][FAILURE_KEY][RUN_AFTER_KEY].to_i rescue 0
        ret << url if run_after > 10.years.from_now.to_i
      end
      ret
    end
    # rubocop:enable Style/RescueModifier

    def get_notification_urls(event = nil)
      subscription_array = self.events['subscriptions'] ||= []
      ret = []
      if event
        subscription_array.each { |h| ret << h['urls'] if h['event']&.eql? event }
      else
        subscription_array.each { |h| ret << h['urls'] }
      end
      ret.flatten.uniq
    end

  #   def self.get_notification_urls2(api_name:, consumer_id:, event:)
  #     sql = "
  #       select distinct (event_json.sub_event_array -> 'urls') as event_urls
  #       from (
  #         select jsonb_array_elements(subs.api_consumer_subscriptions) as sub_event_array
  #         from (
  #           select a.events -> 'subscriptions' as api_consumer_subscriptions
  #           from webhooks_subscriptions a
  #           where a.api_name = $1
  #           and a.consumer_id = $2
  #           and a.events -> 'subscriptions' is not null
  #         ) as subs
  #       ) as event_json
  #       where event_json.sub_event_array ->> 'event' = $3
  #     "
  #     retrieve_event_urls(sql, api_name, consumer_id, event)
  #   end
  #
  #   def self.retrieve_event_urls(sql, *args)
  #     result = ActiveRecord::Base.connection_pool.with_connection do |c|
  #       c.raw_connection.exec_params(sql, args).to_a
  #     end
  #
  #     result = JSON.parse(result.first['event_urls']).uniq if result.length.positive?
  #     result
  #   end
  end
end
