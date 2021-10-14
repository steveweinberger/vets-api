# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class OAuthController < ApplicationController
    include Warden::GitHub::SSO

    before_action :authenticate!, only: [:index]
    before_action :authorize!, only: [:index]

    def index
      redirect_to "http://localhost:8000/signin"
    end

    def unauthorized
      head :unauthorized
    end

    def is_authorized
      render json: @current_user if authorized?
    end

    def logout
      warden.logout(:tud)
      redirect_to "http://localhost:8000/"
    end
  end
end
