# frozen_string_literal: true

# environment specific redis host and port (see: config/redis.yml)
REDIS_CONFIG = Rails.application.config_for(:redis).freeze
# set the current global instance of Redis based on environment specific config
# This is raising deprecation warnings because a ActiveSupport::OrderedOptions won't support string keys in Rails 6.1

secondary_redis = Redis.new(host: Settings.redis_secondary.host, port: Settings.redis_secondary.port)

class RedisDuplicator < Redis
  def initialize(secondary_redis, options = {})
    @secondary_redis = secondary_redis
    super(options)
  end

  def set(key, value, options = {})
    super
    @secondary_redis.set(key, value, options)
  end

  def del(*keys)
    super
    @secondary_redis.del(keys)
  end

  def expire(key, seconds)
    super
    @secondary_redis.expire(key, seconds)
  end
end

Redis.current = RedisDuplicator.new(secondary_redis, REDIS_CONFIG[:redis])
