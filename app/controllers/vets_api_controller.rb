# frozen_string_literal: true

class VetsApiController < ApplicationController
  include ActionController::RequestForgeryProtection

  before_action :validate_csrf_token!, if: -> do
    ActionController::Base.allow_forgery_protection && request.method != 'GET'
  end
  after_action :set_csrf_cookie, if: -> { request.method == 'GET' } # REVIEW should this be on all responses?

  protected

  def set_csrf_cookie
    cookies['X-CSRF-Token'] = form_authenticity_token
  end

  def validate_csrf_token!
    if request.headers['X-CSRF-Token'].nil? || request.headers['X-CSRF-Token'] != cookies['X-CSRF-Token']
      # for now we are just logging when there's no CSRF protection
      log_message_to_sentry('Request susceptible to CSRF', :info, { controller: self.class, action: action_name })
      # when this is going to be enforced return a meaningful error (and turn up logging level)
    end
  end
end
