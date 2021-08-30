# frozen_string_literal: true

require './lib/webhooks/utilities'
module Webhooks
  class MaintenanceSerializer < ActiveModel::Serializer
    attributes :api_name, :consumer_id, :consumer_name, :maintenance

    def maintenance
      puts "HMMMMMMMMM"
      object.metadata.select do |key, value|
        value.is_a?(Hash) && value.has_key?(Webhooks::Subscription::MAINTENANCE_KEY)
      end
    end
  end
end
