# frozen_string_literal: true

require './lib/webhooks/utilities'
module Webhooks
  class SubscriptionSerializer < ActiveModel::Serializer
    attributes :api_name, :consumer_name, :current_subscription
    attribute :previous_subscription, if: :previously_subscribed?


    def current_subscription
      object.events
    end

    def previously_subscribed?
      @previous_subscription = @instance_options[:previous_subscription]
      !@previous_subscription.nil?
    end

    attr_reader :previous_subscription
  end
end
