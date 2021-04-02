module ClaimsApi
  module V2
    class IntentToFiles < ClaimsApi::V2::Base
      version 'v2'

      resource 'veterans/:veteranId' do
        resource 'intent-to-files' do
          desc 'Submit an intent to file.' do
            detail ''
            success ClaimsApi::Entities::V2::ClaimSubmittedEntity
            failure [
              [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
              [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
            ]
            tags ['Intent to Files']
            security [{ bearer_token: [] }]
          end
          params do
            requires :token, type: String
          end
          post '/' do
            raise 'NotImplemented'
          end

          desc 'Return all intent to files associated with Veteran.' do
            detail <<~X
              Returns pending claims submitted through this API as well as any established claims submitted
              from other sources.
            X
            success ClaimsApi::Entities::V2::ClaimEntity
            failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
            tags ['Intent to Files']
            security [{ bearer_token: [] }]
          end
          params do
            requires :token, type: String
          end
          get '/' do
            non_established_claims = ClaimsApi::AutoEstablishedClaim.where(source: source_name)
                                                                    .where('evss_id is null')
            established_claims = ClaimsApi::AutoEstablishedClaim.where(source: source_name)
                                                                .where('evss_id is not null')
            evss_claims = claims_service.all

            merged_claims = non_established_claims.to_a
            evss_claims.each do |evss_claim|
              our_claim = established_claims.find do |established_claim|
                            established_claim.evss_id.to_i == evss_claim.evss_id
                          end
              our_claim.present? ? merged_claims.push(our_claim) : merged_claims.push(evss_claim)
            end

            present merged_claims, with: ClaimsApi::Entities::V2::ClaimEntity, base_url: request.base_url
          end

        end
      end
    end
  end
end
