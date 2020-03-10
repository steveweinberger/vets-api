# frozen_string_literal: true

class VetsApiController < ApplicationController
  include ActionController::RequestForgeryProtection

  before_action :validate_csrf_token!, if: -> { request.method != 'GET' }
  after_action :set_csrf_cookie, if: -> { request.method == 'GET' }

  protected

  def set_csrf_cookie
    cookies['X-CSRF-Token'] = form_authenticity_token
  end

  def validate_csrf_token!
    if request.headers['X-CSRF-Token'].nil? || request.headers['X-CSRF-Token'] != cookies['X-CSRF-Token']
      raise ActionController::InvalidAuthenticityToken
    end
  end
end
