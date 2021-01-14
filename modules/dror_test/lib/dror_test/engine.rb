# frozen_string_literal: true

module DrorTest
  class Engine < ::Rails::Engine
    isolate_namespace DrorTest
    config.generators.api_only = true
  end
end
