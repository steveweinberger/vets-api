module Lighthouse::ClinicalHealth
  class JwtWrapper
    VERSION = 2.1
    def payload
      {
        iss: Settings.lighthouse.clinical_health.condition_client_id,
        sub: Settings.lighthouse.clinical_health.condition_client_id,
        aud: Settings.lighthouse.clinical_health.condition_aud_claim_url,
        exp: 15.minutes.from_now.to_i
      }
    end

    def token
      @token ||= JWT.encode(payload, Configuration.instance.rsa_key, 'RS256')
    end
  end
end
