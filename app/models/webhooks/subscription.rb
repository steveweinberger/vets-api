# frozen_string_literal: true

module Webhooks
  class Subscription < ApplicationRecord
    self.table_name = 'webhooks_subscriptions'

    has_many :webhooks_notifications, :class_name => 'Webhooks::Notification'
    BLOCKED_CALLBACK = 100.years.from_now
    FAILURE_KEY = 'failure_hash'
    MAINTENANCE_KEY = 'maintenance_hash'
    UNDER_MAINT_KEY = 'under_maintenance'
    RUN_AFTER_KEY = 'run_after_epoch'

    def blocked_callback_urls
      metadata = self.metadata
      ret = []
      metadata.keys.each do |url|
        run_after = metadata[url][FAILURE_KEY][RUN_AFTER_KEY].to_i rescue 0
        ret << url if run_after > 10.years.from_now.to_i
      end
      ret
    end

    def self.get_notification_urls(api_name:, consumer_id:, event:)
      sql = "
        select distinct (event_json.sub_event_array -> 'urls') as event_urls
        from (
          select jsonb_array_elements(subs.api_consumer_subscriptions) as sub_event_array
          from (
            select a.events -> 'subscriptions' as api_consumer_subscriptions
            from webhooks_subscriptions a
            where a.api_name = $1
            and a.consumer_id = $2
            and a.events -> 'subscriptions' is not null
          ) as subs
        ) as event_json
        where event_json.sub_event_array ->> 'event' = $3
      "
      retrieve_event_urls(sql, api_name, consumer_id, event)
    end

    def self.retrieve_event_urls(sql, *args)
      result = ActiveRecord::Base.connection_pool.with_connection do |c|
        c.raw_connection.exec_params(sql, args).to_a
      end

      if result.length.positive?
        result = JSON.parse(result.first['event_urls']).uniq
      end
      result
    end
  end
end
