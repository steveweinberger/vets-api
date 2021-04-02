require 'evss/disability_compensation_auth_headers'
require 'evss/auth_headers'
require 'claims_api/special_issue_mappers/bgs'

module ClaimsApi
  module V2
    class DisabilityClaims < ClaimsApi::V2::Base
      version 'v2'
      helpers do
        def form_attributes
          params.dig('data', 'attributes') || {}
        end

        def auth_headers
          evss_headers = EVSS::DisabilityCompensationAuthHeaders
                         .new(target_veteran)
                         .add_headers(
                           EVSS::AuthHeaders.new(target_veteran).to_h
                         )
        end

        def flashes
          initial_flashes = form_attributes.dig('veteran', 'flashes')
          homelessness = form_attributes.dig('veteran', 'homelessness')
          is_terminally_ill = form_attributes.dig('veteran', 'isTerminallyIll')

          initial_flashes.push('Homeless') if homelessness.present?
          initial_flashes.push('Terminally Ill') if is_terminally_ill.present? && is_terminally_ill

          initial_flashes.present? ? initial_flashes.uniq : []
        end

        def special_issues_per_disability
          (form_attributes['disabilities'] || []).map { |disability| special_issues_for_disability(disability) }
        end

        def special_issues_for_disability(disability)
          primary_special_issues = disability['specialIssues'] || []
          secondary_special_issues = []
          (disability['secondaryDisabilities'] || []).each do |secondary_disability|
            secondary_special_issues += (secondary_disability['specialIssues'] || [])
          end
          special_issues = primary_special_issues + secondary_special_issues

          mapper = ClaimsApi::SpecialIssueMapper.new
          {
            code: disability['diagnosticCode'],
            name: disability['name'],
            special_issues: special_issues.map { |special_issue| mapper.code_from_name(special_issue) }
          }
        end
      end

      before do
        authenticate
        permit_scopes %w[claim.write]
      end

      resource 'veterans/:veteranId' do
        resource 'claims' do
          resource 'disability-claims' do
            resource 'queue' do
              desc 'Check status of asynchronous claim submission.' do
                detail <<~X
                  Accepts this API's uuid claim identifier to search claims submitted through this API.
                  This endpoint also accepts a VBMS id to search for an established claim from any source.
                X
                success ClaimsApi::Entities::V2::ClaimEntity
                failure [[401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity']]
                tags ['Disability Claims']
                security [{ bearer_token: [] }]
              end
              params do
                requires :token, type: String
                requires :id, type: String, desc: 'Unique claim identifier. Accepts either uuid or VBMS id.'
              end
              route_param :id do
                get do
                  claim = ClaimsApi::AutoEstablishedClaim.get_by_id_or_evss_id(params[:id])
                  claim = claims_service.update_from_remote(params[:id]) if claim.blank?
                  # TODO: figure out all these statuses
                  #   seems statuses are different based on whether we processed the claim or not

                  present claim, with: ClaimsApi::Entities::V2::ClaimEntity, base_url: request.base_url
                end
              end
            end

            desc 'Submit supporting documents for previously submitted disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            params do
              requires :token, type: String
              requires :id, type: String, desc: 'Unique claim identifier.'
            end
            route_param :id do
              post 'supporting-documents' do
                status 202

                raise 'NotImplemented'
              end
            end

            desc 'Submit an original disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            params do
              requires :token, type: String
              requires :data, type: Hash do
                optional :type, type: String, documentation: { param_type: 'body' }
                requires :attributes, type: Hash do
                  requires :veteran, type: Hash do
                    requires :currentlyVAEmployee, type: Boolean
                    # TODO: define necessary schema here
                  end
                end
              end
            end
            post '/original-claims' do
              status 202

              auto_claim = ClaimsApi::AutoEstablishedClaim.create(
                status: ClaimsApi::AutoEstablishedClaim::PENDING,
                auth_headers: auth_headers,
                form_data: form_attributes,
                flashes: flashes,
                special_issues: special_issues_per_disability,
                source: source_name
              )
              unless auto_claim.id
                existing_auto_claim = ClaimsApi::AutoEstablishedClaim.find_by(md5: auto_claim.md5, source: source_name)
                auto_claim = existing_auto_claim if existing_auto_claim.present?
              end

              if auto_claim.errors.present?
                raise Common::Exceptions::UnprocessableEntity.new(detail: auto_claim.errors.messages.to_s)
              end

              ClaimsApi::ClaimEstablisher.perform_async(auto_claim.id)

              present auto_claim, with: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity, base_url: request.base_url
            end

            desc 'Submit an increase disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            post '/increase-claims' do
              status 202

              raise 'NotImplemented'
            end

            desc 'Submit a new disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            post '/new-claims' do
              status 202

              raise 'NotImplemented'
            end

            desc 'Submit a secondary disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            post '/secondary-claims' do
              status 202

              raise 'NotImplemented'
            end

            desc 'Submit a special disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            post '/special-claims' do
              status 202

              raise 'NotImplemented'
            end

            desc 'Submit a supplemental disability claim.' do
              detail ''
              success code: 202, model: ClaimsApi::Entities::V2::DisabilityClaimSubmittedEntity
              failure [
                [401, 'Unauthorized', 'ClaimsApi::Entities::V2::ErrorsEntity'],
                [400, 'Bad Request', 'ClaimsApi::Entities::V2::ErrorsEntity']
              ]
              tags ['Disability Claims']
              security [{ bearer_token: [] }]
            end
            post '/supplemental-claims' do
              status 202

              raise 'NotImplemented'
            end
          end
        end
      end
    end
  end
end
