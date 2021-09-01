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
    before_action :verify_settings, only: [:ping]

    def list
      consumer_id = request.headers['X-Consumer-ID']
      wh = Webhooks::Utilities.fetch_subscriptions(consumer_id)
      # TODO include data about callback urls in maintenance mode
      render status: :ok,
             json: wh,
             serializer: ActiveModel::Serializer::CollectionSerializer,
             each_serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["Invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

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
      ::Webhooks::Utilities.clean_subscription(api_name, @consumer_id) do |subscription|
        if subscription
          maint_key = Webhooks::Subscription::MAINTENANCE_KEY
          metadata = subscription.metadata
          # events = subscription.events['subscriptions'] #todo validate that the url is in the subscription
          urls.each do |url_hash|
            metadata[url_hash['url']] ||= {}
            metadata[url_hash['url']][maint_key] =
              { Webhooks::Subscription::UNDER_MAINT_KEY => url_hash['maintenance'] }
          end
          subscription.metadata = metadata
          subscription.save!
          puts "HEEYYYY"
          render status: :accepted,
                 json: subscription,
                 serializer: Webhooks::MaintenanceSerializer
        else
          puts "YOOOO"
          #  todo what do we return
        end
      end
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    WEBHOOK_PING_PONG_EVENT = 'gov.va.developer.webhooks.ping-pong'
    PING_PONG_API_NAME = 'webhooks-ping-pong'
    REGISTRATION_NEXT_RUN_MINS = Settings.webhooks.ping_pong_next_run_in_minutes
    
    register_events(WEBHOOK_PING_PONG_EVENT,
                    api_name: PING_PONG_API_NAME,
                    max_retries: Settings.webhooks.ping_pong_max_retries || 3) do |last|

      next_run = last ? (REGISTRATION_NEXT_RUN_MINS || WEBHOOK_DEFAULT_RUN_MINS) : 0
      next_run.minutes.from_now
    rescue
      WEBHOOK_DEFAULT_RUN_MINS.minutes.from_now
    end

    def ping
      consumer_id = request.headers['X-Consumer-ID']
      consumer_name = request.headers['X-Consumer-Username']
      wh = Webhooks::Utilities.fetch_subscriptions(consumer_id)
      # TODO what else should be return?
      # # TODO get the real GUID
      remove_me_guid = '59ac8ab0-1f28-43bd-8099-23adb561815a'
      msg = format_msg(consumer_name, consumer_id, REGISTRATION_NEXT_RUN_MINS)
      params = { consumer_id: consumer_id, consumer_name: consumer_name,
                 event: WEBHOOK_PING_PONG_EVENT, api_guid: remove_me_guid, msg: msg }
      Webhooks::Utilities.record_notifications(params)
      render status: :ok,
             json: wh,
             serializer: ActiveModel::Serializer::CollectionSerializer,
             each_serializer: Webhooks::PingPongSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["Invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    # todo place documentation outlining structure of failure data.  Something like:
    #  {"404"=>6, "420"=>4, "503"=>7, "total"=>27, "Faraday::Error"=>6, "Faraday::ClientError"=>4}
    register_failure_handler(api_name: PING_PONG_API_NAME) do |failure_data|
      Rails.logger.info("Webhooks: failure handler got #{failure_data}")
      # {"404"=>6, "420"=>4, "503"=>7, "total"=>27, "Faraday::Error"=>6, "Faraday::ClientError"=>4}
      next_run =
        case failure_data['total']
        when 1..3
          0.minutes.from_now
        when 4..10
          5.minutes.from_now
          # when 11..20
          #   20.minutes.from_now
          # when 21..50
          #   40.minutes.from_now
        else
          Webhooks::Subscription::BLOCKED_CALLBACK
        end

      next_run
    end

    def report
    # stats - counts of failures, etc.
    end

    def subscribe
      # TODO: use new atomic read method
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

      prev_subscription = Webhooks::Utilities.fetch_subscription(@consumer_id, subscriptions)
      new_subscription = Webhooks::Utilities.register_webhook(@consumer_id, @consumer_name, subscriptions)
      Webhooks::Utilities.clean_subscription(new_subscription.api_name, new_subscription.consumer_id) do |s|
        save_metadata(s)
      end
      render status: :accepted,
             json: new_subscription,
             previous_subscription: prev_subscription&.events,
             serializer: Webhooks::SubscriptionSerializer
    rescue JSON::ParserError => e
      raise Common::Exceptions::SchemaValidationErrors, ["invalid JSON. #{e.message}"] if e.is_a? JSON::ParserError
    end

    def save_metadata(subscription)
      urls = subscription.events['subscriptions'].map { |sub| sub['urls'] }.flatten
      removed_urls = []
      # we remove metadata of any urls that aren't in the request
      subscription.metadata.keep_if do |k, _|
        if urls.include? k
          k
        else
          removed_urls.push(k)
          false
        end
      end
      # clear out the failure metadata
      subscription.metadata.each do |m|
        m[1]['failure_hash'] = {}
      end
      handle_deleted_urls(removed_urls)
      subscription.save!
    end

    def verify_consumer
      @consumer_name = request.headers['X-Consumer-Username'] #before_action to set consumer information
      @consumer_id = request.headers['X-Consumer-ID']
      render plain: 'Consumer data not found', status: :not_found unless @consumer_id && @consumer_name
    end

    def verify_settings
      render plain: 'Not found', status: :not_found unless Settings.webhooks.ping_pong_enabled
    end

    def format_msg(consumer_name, consumer_id, time_from_now)
      msg = {}
      msg['message'] = "The ping event will fire in #{time_from_now} minutes from now"
      msg['api_name'] = PING_PONG_API_NAME
      msg['consumer_name'] = consumer_name
      msg['consumer_id'] = consumer_id
      msg['event'] = WEBHOOK_PING_PONG_EVENT
      msg['epoch_time'] = Time.current.to_i
      msg
    end

  end

end
