# frozen_string_literal: true

require './lib/webhooks/utilities'
module Webhooks
  class PingPongSerializer < ActiveModel::Serializer
    attributes  :api_name, :consumer_name, :consumer_id, :metadata
  end
  # TODO craft a clever message
  def metadata
    object.metadata
  end

end
