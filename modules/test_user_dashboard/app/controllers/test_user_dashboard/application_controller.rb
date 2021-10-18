# frozen_string_literal: true

require 'sentry_logging'

module TestUserDashboard
  class ApplicationController < ActionController::API
    include SentryLogging

    attr_reader :current_user

    private

    def authenticate!
      return if authenticated?

      warden.authenticate!(scope: :tud)
      # does returning head :forbidden work with the warden-github gem?
      head :forbidden unless authenticated?
    end

    def authenticated?
      return true if Rails.env.test?

      if warden.authenticated?(:tud)
        set_current_user
        Rails.logger.info("TUD authentication successful: #{github_user_details}")
        return true
      end

      Rails.logger.info('TUD authentication unsuccessful')
      false
    end

    def authorize!
      authorized?
    end

    def authorized?
      if authenticated?
        # if authenticated? && github_user.organization_member?('department-of-veterans-affairs')
        Rails.logger.info("TUD authorization successful: #{github_user_details}")
        true
      else
        Rails.logger.info("TUD authorization unsuccessful: #{github_user_details}") if authenticated?
        false
      end
    end

    def github_user
      warden.user(:tud)
    end

    def github_user_details
      "ID: #{github_user.id}, Login: #{github_user.login}, Name: #{github_user.name}, Email: #{github_user.email}"
    end

    def set_current_user
      @current_user = {
        id: github_user.id,
        login: github_user.login,
        email: github_user.email,
        name: github_user.name,
        avatar_url: github_user.avatar_url
      }
    end

    def warden
      request.env['warden']
    end
  end
end
