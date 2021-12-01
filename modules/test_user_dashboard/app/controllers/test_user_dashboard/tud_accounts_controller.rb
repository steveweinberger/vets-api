# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class TudAccountsController < ApplicationController
    # include Warden::GitHub::SSO

    # before_action :authenticate!
    # before_action :authorize!

    def index
      render json: TestUserDashboard::TudClient.all
    end

    def update
      tud_account = TudClient.find(params[:id])
      tud_account.notes = params[:notes]
      tud_account.save
      render json: tud_account
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }
    end
  end
end
