# frozen_string_literal: true

require 'common/exceptions'

module V1::Webhooks
  class RegistrationController < ApplicationController
    include Webhooks::Utilities
    skip_before_action(:verify_authenticity_token)
    skip_after_action :set_csrf_header
    skip_before_action :set_tags_and_extra_context, raise: false
    skip_before_action(:authenticate)
    before_action(:verify_consumer)

    def list
      #  todo mandate api_name to simplify rspec tests. We don't have to spoof subscriptions across apis to test the list method
      api_name = params['api_name']
      consumer_id = params['consumer_id']
      unless api_name || consumer_id
        raise Common::Exceptions::ParameterMissing.new(
          'webhook',
          detail: 'You must provide an API Name or Consumer ID!'
        )
      end
      if consumer_id
        wh = Webhooks::Utilities.fetch_subscriptions(consumer_id)
      elsif api_name
        wh = Webhooks::Utilities.fetch_subscriptions_by_api_name(api_name)
      end

      render status: :ok,
             json: wh,
             serializer: ActiveModel::Serializer::CollectionSerializer,
             each_serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
        raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
      #include data about callback urls in maintenance mode
    end

    def maintenance
    #  api_name?
      urls = params['callback_urls']
      action_flag = params['on_off_flag']

      # todo validate that these are their urls based on current subscriptions
    #  write to new table with consumer, api_name, callback_url, jsonb, maintenance y/n (default n)
    end

    def report
    # stats - counts of failures, etc.
    end

    def subscribe
      # todo kevin - ensure we have an rspec test that you can only subscribe to one api / subscription
      # todo all events must be under one api_name in the subscription
      webhook = params[:webhook]
      unless webhook
        raise Common::Exceptions::ParameterMissing.new(
          'webhook',
          detail: 'You must provide a webhook subscription!'
        )
      end

      subscription_json = webhook.respond_to?(:read) ? webhook.read : webhook
      subscriptions = validate_subscription(JSON.parse(subscription_json))

      prev_wh = Webhooks::Utilities.fetch_subscription(@consumer_id, subscriptions)
      wh = Webhooks::Utilities.register_webhook(@consumer_id, @consumer_name, subscriptions)
      render status: :accepted,
             json: wh,
             previous_subscription: prev_wh&.events,
             serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    def verify_consumer
      @consumer_name = request.headers['X-Consumer-Username'] #before_action to set consumer information
      @consumer_id = request.headers['X-Consumer-ID']
      render plain: 'Consumer data not found', status: :not_found unless @consumer_id && @consumer_name
    end

  end

end
