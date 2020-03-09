# frozen_string_literal: true

class VetsApiController < ApplicationController
  include ActionController::RequestForgeryProtection

  before_action :validate_csrf_token!, if: -> { request.method != 'GET' }
  after_action :set_csrf_cookie, if: -> { request.method == 'GET' }
end
