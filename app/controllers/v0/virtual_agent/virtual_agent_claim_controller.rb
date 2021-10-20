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
        claimAugmenter = ClaimAugmenter.new
        data = synchronized == 'REQUESTED' ? nil : claimAugmenter.getSupplementalClaimData(open_comp_claims_data, current_user, service)
        puts('data with extra details')
        puts(data)

        render json: {
          data: data,
          meta: { sync_status: synchronized }
        }
      end

      def show
        puts('in show')
        claim = EVSSClaim.for_user(current_user).find_by(evss_id: params[:id])

        claim, synchronized = service.update_from_remote(claim)
        puts(claim)
        puts(synchronized)

        render json: {
          data: { va_representative: get_va_representative(claim) },
          meta: { sync_status: synchronized }
        }
      end

      class ClaimAugmenter
        include Concurrent::Async

        def getSupplementalClaimData(claims, current_user, service)
          puts('made it!!')
          claimsWithSupplementalData = claims.map do |claim|
            puts('in map!!')
            puts(claim)
            claim_db_record = EVSSClaim.for_user(current_user).find_by(evss_id: claim[:evss_id])
            single_claim_response = {}
            synchronized = 'REQUESTED'
            until synchronized == 'SUCCESS' do
              single_claim_response, synchronized = service.update_from_remote(claim_db_record)
              if synchronized == 'REQUESTED' then sleep(10) end
            end
            transform_single_claim_to_augmented_response(claim, single_claim_response)
          end
          puts('finished transofrming list of claims')
          puts(claimsWithSupplementalData)
          return claimsWithSupplementalData
        end

        def transform_single_claim_to_augmented_response(claim, claim_db_record)
          puts('inside augment claim')
          va_representative = get_va_representative(claim_db_record)
          puts(va_representative)
          return { claim_status: claim[:claim_status],
                   claim_type: claim[:claim_type],
                   filing_date: claim[:filing_date],
                   evss_id: claim[:evss_id],
                   updated_date: claim[:updated_date],
                   va_representative: va_representative
          }
        end

        def get_va_representative(claim)
          va_rep = claim.data['poa']
          va_rep.gsub(/&[^ ;]+;/, '')
        end

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

        { claim_status: claim_status,
          claim_type: status_type,
          filing_date: filing_date,
          evss_id: evss_id,
          updated_date: updated_date
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
