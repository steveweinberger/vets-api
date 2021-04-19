# frozen_string_literal: true

module ClaimsApi
  module V2
    class VeteranIdGeneratorController < ApplicationController
      def create
        # TODO: authorization here
        verify_mpi

        render json: { id: target_veteran.mpi.icn }
      end

      protected

      def target_veteran_info
        params
      end
    end
  end
end
