# frozen_string_literal: true

require 'sidekiq'

module Mobile
  module V0
    class FillMobileUserTableJob
      include Sidekiq::Worker

      sidekiq_options(retry: false)

      def perform(uuid, icn)
        resource = Mobile::V0::Users.new(user_id: icn)
        resource.save!
        Rails.logger.info('Mobile user table add succeeded for user with icn and uuid',
                          { user_uuid: uuid, icn: icn })
      rescue => e
        Rails.logger.error('Mobile user table add failed for user with icn and uuid',
                           { user_uuid: uuid, icn: icn })
        raise e
      ensure
        redis = Redis::Namespace.new(REDIS_CONFIG[:mobile_user_table_lock][:namespace], redis: Redis.current)
        redis.del(uuid)
      end
    end
  end
end
