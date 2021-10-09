# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class TudAccountsController < ApplicationController
    include ActionView::Helpers::SanitizeHelper
    include Warden::GitHub::SSO

    before_action :authorize!

    def index
      payload = {
        tud_accounts: TudAccount.all,
        user: @current_user
      }

      render json: payload
    end

    def update
      tud_account = TudAccount.find(params[:id])
      sanitized_notes = sanitize params[:notes]
      tud_account.update!(notes: sanitized_notes)
      render json: tud_account
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }
    end
  end
end
