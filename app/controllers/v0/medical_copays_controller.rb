# frozen_string_literal: true

module V0
  class MedicalCopaysController < ApplicationController
    before_action { authorize :medical_copays, :access? }

    def index
      render json: vbs_service.get_copays
    end

    def show
      render json: vbs_service.get_copays_by_id(params[:statement_id])
    end

    def get_pdf_statement_by_id
      send_data(
        vbs_service.get_pdf_statement_by_id(params[:statement_id]),
        type: 'application/pdf',
        filename: 'stament.pdf'
      )
    end

    private

    def vbs_service
      MedicalCopays::VBS::Service.build(user: current_user)
    end
  end
end
