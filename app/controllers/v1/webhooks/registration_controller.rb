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

  end

end
