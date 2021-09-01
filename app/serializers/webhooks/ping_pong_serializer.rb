# frozen_string_literal: true

require './lib/webhooks/utilities'
module Webhooks
  class PingPongSerializer < ActiveModel::Serializer
    attributes  :api_name, :consumer_name, :consumer_id
    # attribute :message
  end
  # TODO craft a clever message
  # def message
  #   @message = "The ping event will fire in #{Settings.webhooks.ping_pong_next_run_in_minutes} minutes from now"
  # end

  # attr_reader :message
end