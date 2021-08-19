# frozen_string_literal: true

require './lib/webhooks/utilities'
module Webhooks
  class SubscriptionSerializer < ActiveModel::Serializer
    attributes :api_name, :consumer_name, :current_subscription, :consumer_id, :events
    attribute :previous_subscription, if: :previously_subscribed?

    def current_subscription
      object.events
    end

    def previously_subscribed?
      @previous_subscription = @instance_options[:previous_subscription]
      !@previous_subscription.nil?
    end

    attr_reader :previous_subscription, :api_name
  end
end
