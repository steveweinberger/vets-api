module ClaimsApi
  module V2
    class PowerOfAttorney < ClaimsApi::V2::Base
      version 'v2'
      helpers do
        def bgs_service
          BGS::Services.new(
            external_uid: target_veteran.participant_id,
            external_key: target_veteran.participant_id
          )
        end
      end

      before do
        authenticate
        permit_scopes %w[claim.read]
      end

      resource 'veterans/:veteranId' do
        resource 'power-of-attorney' do
          desc 'Return current power of attorney for a Veteran.' do
            detail ''
            # success ClaimsApi::Entities::V2::ClaimEntity
            failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
            tags ['Power of Attorney']
            security [{ bearer_token: [] }]
          end
          params do
            requires :veteranId, type: String
          end
          get '/' do
            pending_poas = ClaimsApi::PowerOfAttorney.where(status: ClaimsApi::PowerOfAttorney::PENDING).each do |poa|
              poa.status = 'active'
            end
            historical_poas = bgs_service.org.find_poas_by_ptcpnt_id(target_veteran.participant_id) || []
            merged_poas = pending_poas + historical_poas

            present merged_poas, with: ClaimsApi::Entities::V2::PowerOfAttorneyEntity, base_url: request.base_url
          end

          desc 'Veteran access to change their power of attorney.' do
            detail ''
            # success ClaimsApi::Entities::V2::ClaimEntity
            failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
            tags ['Power of Attorney']
            security [{ bearer_token: [] }]
          end
          params do
            requires :veteranId, type: String
          end
          put '/' do
            pending_poas = ClaimsApi::PowerOfAttorney.where(status: ClaimsApi::PowerOfAttorney::PENDING).each do |poa|
              poa.status = 'active'
            end
            historical_poas = bgs_service.org.find_poas_by_ptcpnt_id(target_veteran.participant_id) || []
            merged_poas = pending_poas + historical_poas

            present merged_poas, with: ClaimsApi::Entities::V2::PowerOfAttorneyEntity, base_url: request.base_url
          end

          desc 'Representative option to request a power of attorney change for Veteran.' do
            detail ''
            # success ClaimsApi::Entities::V2::ClaimEntity
            failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
            tags ['Power of Attorney']
            security [{ bearer_token: [] }]
          end
          params do
            requires :veteranId, type: String
          end
          post '/requests' do
            pending_poas = ClaimsApi::PowerOfAttorney.where(status: ClaimsApi::PowerOfAttorney::PENDING).each do |poa|
              poa.status = 'active'
            end
            historical_poas = bgs_service.org.find_poas_by_ptcpnt_id(target_veteran.participant_id) || []
            merged_poas = pending_poas + historical_poas

            present merged_poas, with: ClaimsApi::Entities::V2::PowerOfAttorneyEntity, base_url: request.base_url
          end

          resource 'queue' do
            desc 'Check status of asynchronous power of attorney change/request.' do
              detail ''
              # success ClaimsApi::Entities::V2::ClaimEntity
              failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
              tags ['Power of Attorney']
              security [{ bearer_token: [] }]
            end
            params do
              requires :veteranId, type: String
            end
            route_param :id do
              get do
                pending_poas = ClaimsApi::PowerOfAttorney.where(status: ClaimsApi::PowerOfAttorney::PENDING).each do |poa|
                  poa.status = 'active'
                end
                historical_poas = bgs_service.org.find_poas_by_ptcpnt_id(target_veteran.participant_id) || []
                merged_poas = pending_poas + historical_poas

                present merged_poas, with: ClaimsApi::Entities::V2::PowerOfAttorneyEntity, base_url: request.base_url
              end
            end
          end
        end
      end
    end
  end
end
