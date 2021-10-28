# frozen_string_literal: true

require 'dgi/configuration'
require 'common/client/base'

module DGI
  class Service

    def initialize(user)
      @user = user
    end

    def self.process(**args)
      new(args).process
    end
  end
end
