# frozen_string_literal: true

require 'date'
require 'concurrent'

module V0
  module VirtualAgent
    class VirtualAgentClaimController < ApplicationController
      include IgnoreNotFound

      before_action { authorize :evss, :access? }

      def index
        claims, synchronized = service.all

        open_comp_claims_data = synchronized == 'REQUESTED' ? nil : data_for_three_most_recent_open_comp_claims(claims)
        puts(open_comp_claims_data)
        x = ClaimAugmenter.new
        data = synchronized == 'REQUESTED' ? nil : x.getSupplementalClaimData(open_comp_claims_data, current_user)
        puts(data)

        render json: {
          data: data,
          meta: { sync_status: synchronized }
        }
      end

      def show
        claim = EVSSClaim.for_user(current_user).find_by(evss_id: params[:id])

        claim, synchronized = service.update_from_remote(claim)

        render json: {
          data: { va_representative: get_va_representative(claim) },
          meta: { sync_status: synchronized }
        }
      end



# const arr = [claim,1 claim2, claim3];
#
# const asyncRes = await Promise.all(arr.map(async (claim) => {
# 	await callApiUntilSyncStatusIsSuccess;
# 	return claimWithRepAppended;
# }));`

      # def callApiUntilSyncStatusIsSuccess {
      #   while syncStatus == REQUESTED {
      #     sleep(1)
      #     keep calling the API
      #   }
      # }


      class ClaimAugmenter
        include Concurrent::Async

        def getSupplementalClaimData(claims, current_user)
          puts('made it!!')
          # puts(logged_in?)
          # puts(current_user)
          # puts(@current_user)
          claims.map do |claim|
            puts('in map!!')
            puts(claim[:evss_id])
            puts('random1')
            # puts(current_user)
            puts('random2')
            claim_db_record = EVSSClaim.for_user(current_user).find_by(evss_id: claim[:evss_id])
            puts(claim_db_record)
            puts('before empty obj')
            single_claim_response = {}
            puts('after empty obj')
            synchronized = 'REQUESTED'
            until synchronized == 'SUCCESS' do
              sleep(10)
              puts(synchronized)
              single_claim_response, synchronized = service.update_from_remote(claim_db_record)
              puts(synchronized)
              puts(single_claim_response)
            end
            transform_single_claim_to_augmented_response(claim, single_claim_response)
          end
        end
      end

      def transform_single_claim_to_augmented_response(claim, claim_db_record)
        status_type = claim.list_data['status_type']
        claim_status = claim.list_data['status']
        filing_date = claim.list_data['date']
        evss_id = claim.list_data['id']
        updated_date = get_updated_date(claim)
        va_representative = get_va_representative(claim_db_record)

        { claim_status: claim_status,
          claim_type: status_type,
          filing_date: filing_date,
          evss_id: evss_id,
          updated_date: updated_date,
          va_representative: va_representative
        }
      end




          private

      def data_for_three_most_recent_open_comp_claims(claims)
        comp_claims = three_most_recent_open_comp_claims claims

        return [] if comp_claims.nil?

        transform_claims_to_response(comp_claims)
      end

      def transform_claims_to_response(claims)
        claims.map { |claim| transform_single_claim_to_response(claim) }
      end

      def transform_single_claim_to_response(claim)
        status_type = claim.list_data['status_type']
        claim_status = claim.list_data['status']
        filing_date = claim.list_data['date']
        evss_id = claim.list_data['id']
        updated_date = get_updated_date(claim)

        # # claim_supplement = EVSSClaim.for_user(current_user).find_by(evss_id: params[:id])
        # claim_supplement = EVSSClaim.for_user(current_user).find_by(evss_id: evss_id)

        { claim_status: claim_status,
          claim_type: status_type,
          filing_date: filing_date,
          evss_id: evss_id,
          updated_date: updated_date
          # va_representative: get_va_representative(claim_supplement)
        }
      end

      def three_most_recent_open_comp_claims(claims)
        claims
          .sort_by { |claim| parse_claim_date claim }
          .reverse
          .select { |claim| open_compensation? claim }
          .take(3)
      end

      def service
        EVSSClaimServiceAsync.new(current_user)
      end

      def parse_claim_date(claim)
        Date.strptime get_updated_date(claim), '%m/%d/%Y'
      end

      def get_updated_date(claim)
        claim.list_data['claim_phase_dates']['phase_change_date']
      end

      def open_compensation?(claim)
        claim.list_data['status_type'] == 'Compensation' and !claim.list_data.key?('close_date')
      end

      def get_va_representative(claim)
        va_rep = claim.data['poa']
        va_rep.gsub(/&[^ ;]+;/, '')
      end
    end
  end
end
