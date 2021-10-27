# frozen_string_literal: true

require 'dgi/configuration'
require 'common/client/base'

module DGI
  class Service
    include Common::Client::Concerns::Monitoring
    include SentryLogging

    def initialize(user)
      @user = user
    end
  end
end
