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
    # load './app/models/webhooks/utilities.rb'
    before_action :verify_settings, only: [:ping]

    def list
      consumer_id = request.headers['X-Consumer-ID']
      wh = Webhooks::Subscription.list_subscriptions(consumer_id)
      render status: :ok,
             json: wh,
             serializer: ActiveModel::Serializer::CollectionSerializer,
             each_serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["Invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    # rubocop:disable Metrics/MethodLength
    def maintenance
      maint = params[:webhook_maintenance]
      unless maint
        raise Common::Exceptions::ParameterMissing.new(
            'webhook_maintenance',
            detail: 'You must provide a webhook_maintenance parameter!'
        )
      end

      maint = maint.respond_to?(:read) ? maint.read : maint
      maint_hash = validate_maintenance(JSON.parse(maint), @consumer_id)
      api_name = maint_hash['api_name']
      urls = maint_hash['urls']

      # get the subscription for this api_name and consumer_id
      Webhooks::Subscription.clean_subscription(api_name, @consumer_id) do |subscription|
        if subscription
          maint_key = Webhooks::Subscription::MAINTENANCE_KEY
          metadata = subscription.metadata
          urls.each do |url_hash|
            metadata[url_hash['url']] ||= {}
            metadata[url_hash['url']][maint_key] =
                {Webhooks::Subscription::UNDER_MAINT_KEY => url_hash['maintenance']}
          end
          subscription.metadata = metadata
          subscription.save!
          render status: :accepted,
                 json: subscription,
                 serializer: Webhooks::MaintenanceSerializer
          # else
          # TODO: what do we return
        end
      end
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    # rubocop:enable Metrics/MethodLength

    WEBHOOK_PING_PONG_EVENT = 'gov.va.developer.webhooks.ping-pong'
    PING_PONG_API_NAME = 'webhooks-ping-pong'
    REGISTRATION_NEXT_RUN_MINS = Settings.webhooks.ping_pong_next_run_in_minutes

    def ping
      consumer_id = request.headers['X-Consumer-ID']
      consumer_name = request.headers['X-Consumer-Username']
      wh = Webhooks::Subscription.where(consumer_id: consumer_id, api_name: PING_PONG_API_NAME)&.first
      # TODO what else should be return?
      # # TODO get the real GUID
      remove_me_guid = '59ac8ab0-1f28-43bd-8099-23adb561815a'
      msg = format_msg(consumer_name, consumer_id)
      params = { consumer_id: consumer_id, consumer_name: consumer_name,
                 event: WEBHOOK_PING_PONG_EVENT, api_guid: remove_me_guid, msg: msg }
      begin
        Webhooks::Utilities.record_notifications(params)
        wh.metadata["message"] = "The ping event will fire in #{Settings.webhooks.ping_pong_next_run_in_minutes} minute from now"
        wh.save!
        render status: :ok,
               json: wh,
               serializer: Webhooks::PingPongSerializer
        rescue Common::Exceptions::RecordNotFound => e
          error = { detail: 'You must first subscribe to a webhook using the /register endpoint.'}
          render json: { errors: [error] }, status: :not_found
      end

    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["Invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end


    def report
      # stats - counts of failures, etc.
    end

    def subscribe
      # todo kevin - ensure we have an rspec test that you can only subscribe to one api / subscription
      # todo all events must be under one api_name in the subscription
      webhook = params[:webhook]
      unless webhook
        raise Common::Exceptions::ParameterMissing.new('webhook',
                                                       detail: 'You must provide a webhook subscription!'
        )
      end

      subscription_json = webhook.respond_to?(:read) ? webhook.read : webhook
      webhook_subscription = validate_subscription(JSON.parse(subscription_json))
      prev_subscription = nil
      new_subscription = Webhooks::Utilities.register_webhook(@consumer_id, @consumer_name, webhook_subscription) do
      |old_subscription, subscription|
        prev_subscription = old_subscription
        metadata = subscription.metadata
        new_urls = subscription.get_notification_urls
        prev_urls = old_subscription&.get_notification_urls || []
        deleted_urls = prev_urls - new_urls

        new_metadata = {}
        metadata.each_key do |url|
          unless deleted_urls.include? url
            new_metadata[url] = {}
            new_metadata[url][Webhooks::Subscription::FAILURE_KEY] = {}

            # preserve the maintenance information if it is available
            if metadata[url][Webhooks::Subscription::MAINTENANCE_KEY]
              new_metadata[url][Webhooks::Subscription::MAINTENANCE_KEY] =
                  metadata[url][Webhooks::Subscription::MAINTENANCE_KEY]
            end
          end
        end
        subscription.metadata = new_metadata
        subscription.save!
      end

      render status: :accepted,
             json: new_subscription,
             previous_subscription: prev_subscription&.events,
             serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    def verify_consumer
      @consumer_name = request.headers['X-Consumer-Username'] # before_action to set consumer information
      @consumer_id = request.headers['X-Consumer-ID']
      render plain: 'Consumer data not found', status: :not_found unless @consumer_id && @consumer_name
    end

    def verify_settings
      render plain: 'Not found', status: :not_found unless Settings.webhooks.ping_pong_enabled
    end

    def format_msg(consumer_name, consumer_id)
      msg = {}
      msg['message'] = "Pong"
      msg['api_name'] = PING_PONG_API_NAME
      msg['consumer_name'] = consumer_name
      msg['consumer_id'] = consumer_id
      msg['event'] = WEBHOOK_PING_PONG_EVENT
      msg['epoch_time'] = Time.current.to_i
      msg
    end

  end
end
