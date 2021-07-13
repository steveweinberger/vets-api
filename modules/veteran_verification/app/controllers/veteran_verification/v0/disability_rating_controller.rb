# frozen_string_literal: true

require_dependency 'veteran_verification/application_controller'
require_dependency 'notary'

module VeteranVerification
  module V0
    class DisabilityRatingController < ApplicationController
      include ActionController::MimeResponds
      include ClaimsApi::PoaVerification

      NOTARY = VeteranVerification::Notary.new(Settings.vet_verification.key_path)

      before_action { permit_scopes %w[disability_rating.read] }
      before_action :verify_power_of_attorney!, if: :header_request?

      def index
        response = DisabilityRating.for_user(target_veteran)
        serialized = ActiveModelSerializers::SerializableResource.new(
          response,
          each_serializer: VeteranVerification::DisabilityRatingSerializer
        )
        respond_to do |format|
          format.json { render json: serialized.to_json }
          format.jwt { render body: NOTARY.sign(serialized.serializable_hash) }
        end
      end

      private

      def header_request?
        headers_to_check = %w[HTTP_X_VA_SSN
                              HTTP_X_VA_BIRTH_DATE
                              HTTP_X_VA_FIRST_NAME
                              HTTP_X_VA_LAST_NAME]
        (request.headers.to_h.keys & headers_to_check).length.positive?
      end

      def target_veteran(with_gender: false)
        return veteran_from_headers(with_gender: with_gender) if header_request?
        
        ClaimsApi::Veteran.from_identity(identity: @current_user)
      end

      def header(key)
        request.headers[key]
      end

      def veteran_from_headers(with_gender: false)
        vet = ClaimsApi::Veteran.new(
          uuid: header('X-VA-SSN')&.gsub(/[^0-9]/, ''),
          ssn: header('X-VA-SSN')&.gsub(/[^0-9]/, ''),
          first_name: header('X-VA-First-Name'),
          last_name: header('X-VA-Last-Name'),
          va_profile: ClaimsApi::Veteran.build_profile(header('X-VA-Birth-Date')),
          last_signed_in: Time.now.utc,
          loa: @current_user.loa
        )
        vet.mpi_record?
        vet.gender = header('X-VA-Gender') || vet.gender_mpi if with_gender
        vet.edipi = vet.edipi_mpi
        vet.participant_id = vet.participant_id_mpi

        vet
      end
    end
  end
end
