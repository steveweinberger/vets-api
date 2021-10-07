# frozen_string_literal: true

require_dependency 'test_user_dashboard/application_controller'

module TestUserDashboard
  class UnauthorizedController < ApplicationController
    def index
      head :unauthorized
    end
  end
end
