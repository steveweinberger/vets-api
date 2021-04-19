# frozen_string_literal: true

module ClaimsApi
  module V2
    class ApplicationController < ::OpenidApplicationController
      # fetch_audience: defines the audience used for oauth
      # NOTE: required for oauth through claims_api to function
      def fetch_aud
        Settings.oidc.isolated_audience.claims
      end

      protected

      def verify_mpi
        raise ::Common::Exceptions::ResourceNotFound.new(detail: 'Veteran not found') unless target_veteran.mpi_record?
      end

      def target_veteran
        vet = ClaimsApi::Veteran.new(
          uuid: target_veteran_info[:ssn]&.gsub(/[^0-9]/, ''),
          ssn: target_veteran_info[:ssn]&.gsub(/[^0-9]/, ''),
          first_name: target_veteran_info[:firstName],
          last_name: target_veteran_info[:lastName],
          va_profile: ClaimsApi::Veteran.build_profile(target_veteran_info[:birthDate]),
          last_signed_in: Time.now.utc,
          loa: @current_user.loa
        )
        vet.mpi_record?
        vet.edipi = vet.mpi.profile&.edipi
        vet.participant_id = vet.mpi.profile&.participant_id

        vet
      end

      def target_veteran_info
        raise 'NotImplemented'
      end
    end
  end
end
