# frozen_string_literal: true

class Rack::Attack
  # we're behind a load balancer and/or proxy, which is what request.ip returns
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env['X-Real-Ip'] || ip).to_s
    end
  end

  # .to_h because hashes from config_for don't support non-symbol keys
  redis_options = REDIS_CONFIG[:redis].to_h
  Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisStoreProxy.new(Redis.new(redis_options))

  throttle('example/ip', limit: 1, period: 5.minutes) do |req|
    req.ip if req.path == '/v0/limited'
  end

  # Rate-limit PPMS lookup, in order to bore abusers.
  # See https://github.com/department-of-veterans-affairs/va.gov-team-sensitive/blob/master/Postmortems/2021-08-16-facility-locator-possible-DOS.md
  # for details.
  throttle('facility_locator/ip', limit: 3, period: 1.minute) do |req|
    req.remote_ip if req.path == '/facilities_api/v1/ccp/provider'
  end

  throttle('vic_profile_photos_download/ip', limit: 8, period: 5.minutes) do |req|
    req.ip if req.path == '/v0/vic/profile_photo_attachments' && req.get?
  end

  throttle('vic_profile_photos_upload/ip', limit: 8, period: 5.minutes) do |req|
    req.ip if req.path == '/v0/vic/profile_photo_attachments' && req.post?
  end

  throttle('vic_supporting_docs_upload/ip', limit: 8, period: 5.minutes) do |req|
    req.ip if req.path == '/v0/vic/supporting_documentation_attachments' && req.post?
  end

  throttle('vic_submissions/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/v0/vic/vic_submissions' && req.post?
  end

  throttle('evss_claims_async', limit: 12, period: 60) do |req|
    req.ip if req.path == '/v0/evss_claims_async'
  end

  throttle('covid_vaccine', limit: 4, period: 5.minutes) do |req|
    req.remote_ip if req.path.starts_with?('/covid_vaccine/v0') && (req.post? || req.put?)
  end

  throttle('check_in/ip', limit: 10, period: 1.minute) do |req|
    req.remote_ip if req.path.starts_with?('/check_in')
  end

  throttle('medical_copays/ip', limit: 20, period: 1.minute) do |req|
    req.remote_ip if req.path.starts_with?('/v0/medical_copays') && req.get?
  end

  # Source: https://github.com/kickstarter/rack-attack#x-ratelimit-headers-for-well-behaved-clients
  Rack::Attack.throttled_response = lambda do |env|
    rate_limit = env['rack.attack.match_data']

    now = Time.zone.now
    headers = {
      'X-RateLimit-Limit' => rate_limit[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (rate_limit[:period] - now.to_i % rate_limit[:period])).to_i
    }

    [429, headers, ['throttled']]
  end
end
