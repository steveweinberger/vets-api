# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class OAuthController < ApplicationController
    include Warden::GitHub::SSO

    before_action :authorize!

    def index
      redirect_to "http://localhost:8000/signin?code=#{@current_user[:code]}"
    end
  end
end
