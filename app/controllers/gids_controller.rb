# frozen_string_literal: true

class GIDSController < VetsApiController
  skip_before_action :authenticate

  private

  def service
    GIDSRedis.new
  end

  def scrubbed_params
    params.except(:action, :controller, :format)
  end
end
