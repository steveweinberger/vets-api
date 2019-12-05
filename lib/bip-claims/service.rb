# frozen_string_literal: true

module BipClaims
  class Service < Common::Client::Base
    STATSD_KEY_PREFIX = 'api.bip_claims'
    include Common::Client::Monitoring

    configuration BipClaims::Configuration

    def veteran_lookup
      # modules/claims_api/app/controllers/claims_api/application_controller.rb
      # modules/claims_api/app/models/claims_api/veteran.rb
    end

    # rubocop:disable Metrics/MethodLength
    def create_claim(veteran)
      body = {
        "serviceTypeCode": "",
        "programTypeCode": "",
        "benefitClaimTypeCode": "",
        "claimant": {
          "participantId": 0 # TODO: What is the relationship between claimant and veteran?
        },
        "veteran": {
          "participantId": 0,
          "firstName": "",
          "lastName": ""
        },
        "dateOfClaim": DateTime.now.utc.iso8601
      }

      # Raven.extra_context(
      #   request: {
      #     metadata: body['metadata']
      #   }
      # )
      # body['token'] = Settings.central_mail.upload.token

      # response = with_monitoring do
      #   request(
      #     :post,
      #     'upload',
      #     body
      #   )
      # end

      # Raven.extra_context(
      #   response: {
      #     status: response.status,
      #     body: response.body
      #   }
      # )

      # StatsD.increment("#{STATSD_KEY_PREFIX}.upload.fail") unless response.success?

      # response

    end
    # rubocop:enable Metrics/MethodLength

    def benefit_claim_types(query)
      # /api/v1/claims/benefit_claim_types

    end

    def status(uuid_or_list)
      # body = {
      #   'token': Settings.central_mail.upload.token,
      #   'uuid': [*uuid_or_list].to_json
      # }

      # response = request(
      #   :post,
      #   'getStatus',
      #   body
      # )

      # response
    end

    def self.current_breaker_outage?
      last_bc_outage = Breakers::Outage.find_latest(service: BipClaims::Configuration.instance.breakers_service)
      if last_bc_outage.present? && last_bc_outage.end_time.blank?
        BipClaims::Service.new.status('').try(:status) != 200
      end
    end
  end
end
