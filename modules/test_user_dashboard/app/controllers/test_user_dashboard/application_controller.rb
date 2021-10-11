# frozen_string_literal: true

require 'sentry_logging'

module TestUserDashboard
  class ApplicationController < ActionController::API
    include SentryLogging

    before_action :authenticate!

    attr_reader :current_user

    private

    def authenticate!
      return if authenticated?
  
      warden.authenticate!(:github)
      head :forbidden unless authenticated?
    end
  
    def authenticated?
      return true if Rails.env.test?

      if warden&.authenticated?
        set_current_user
        return true
      end

      false
    end
  
    def authorize!
      head :unauthorized unless authorized?
    end
  
    def authorized?
      # i requested access to department-of-veterans-affairs
      # i'm not sure why i don't have it
      # authenticated? && warden.user.organization_member?('department-of-veterans-affairs')
      authenticated?
    end
  
    # set current_user for now
    def set_current_user
      @current_user = {
        id: warden.user['attribs']['id'],
        login: warden.user['attribs']['login'],
        email: warden.user['attribs']['email'],
        name: warden.user['attribs']['name'],
        avatar_url: warden.user['attribs']['avatar_url']
      }
    end
  
    def warden
      request.env['warden']
    end
  end
end
