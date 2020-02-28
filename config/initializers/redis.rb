# frozen_string_literal: true

# REVIEW already established in vets_api_common, but should be passed in via some config

# environment specific redis host and port (see: config/redis.yml)
REDIS_CONFIG = Rails.application.config_for(:redis).freeze
# set the current global instance of Redis based on environment specific config
Redis.current = Redis.new(REDIS_CONFIG['redis'])
