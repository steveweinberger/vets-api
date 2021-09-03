# frozen_string_literal: true

require 'json_schemer'
require 'uri'
require './app/models/webhooks/utilities'

# data structures built up at class load time then frozen.  This is threadsafe.
# rubocop:disable ThreadSafety/InstanceVariableInClassMethod
# rubocop:disable Metrics/ModuleLength
module Webhooks
  module Utilities
    include Common::Exceptions

    SUBSCRIPTION_EX = JSON.parse(File.read('./spec/fixtures/webhooks/subscriptions/subscriptions.json'))
    MAINTENANCE_EX = JSON.parse(File.read('./spec/fixtures/webhooks/maintenance/maintenance.json'))

    class << self
      attr_reader :supported_events, :event_to_api_name, :api_name_to_time_block, :api_name_to_retries,
                  :api_name_to_failure_block

      # Methods here are class methods that do not mix in.

      def included(base)
        base.extend ClassMethods
      end

      def register_name_to_retries(name, retries)
        @api_name_to_retries ||= {}
        @api_name_to_retries[name] = retries.to_i
      end

      def api_registered?(api_name)
        @event_to_api_name.values.include?(api_name)
      rescue
        false
      end

      def register_name_to_event(name, event)
        @event_to_api_name ||= {}
        @event_to_api_name[event] = name
      end

      def register_name_to_failure_block(name, block)
        @api_name_to_failure_block ||= {}
        @api_name_to_failure_block[name] = block
      end

      def register_name_to_time_block(name, block)
        @api_name_to_time_block ||= {}
        @api_name_to_time_block[name] = block
      end

      def register_event(event)
        @supported_events ||= []
        if @supported_events.include?(event)
          raise ArgumentError, "Event: #{event} previously registered! api_name: #{event_to_api_name[event]}"
        end

        @supported_events << event
        @supported_events.uniq!
      end
    end

    module ClassMethods
      # place methods that might be run at class load time here. They mix in as class methods.
      # For example:
      # class Foo
      # include Webhooks::Utilities
      # register_events ...# method is visible as a mixed in class method
      # end

      def register_events(*event, **keyword_args, &block)
        raise ArgumentError, 'Block required to yield next execution time!' unless block_given?
        raise ArgumentError, 'api_name argument required' unless keyword_args.key? :api_name

        api_name = keyword_args[:api_name]
        max_retries = keyword_args[:max_retries]
        raise ArgumentError, 'max_retries argument must be greater than zero' unless max_retries.to_i.positive?
        if Webhooks::Utilities.api_registered?(api_name)
          raise ArgumentError, "api name: #{api_name} previously registered!"
        end

        event.each do |e|
          Webhooks::Utilities.register_event(e)
          Webhooks::Utilities.register_name_to_event(api_name, e)
          Webhooks::Utilities.register_name_to_retries(api_name, max_retries)
          Webhooks::Utilities.register_name_to_time_block(api_name, block)
        end
      end

      def register_failure_handler(api_name:, &block)
        raise ArgumentError, 'Block required to calculate callback url failure retry times!' unless block_given?

        Webhooks::Utilities.register_name_to_failure_block(api_name, block)
      end

      # TODO: move this method out of ClassMethods, it should invoke as an instance method.
      def fetch_events(subscription)
        subscription['subscriptions'].map do |e|
          e['event']
        end.uniq
      end
    end
    extend ClassMethods

    # Validates a subscription request for an upload submission.  Returns an object representing the subscription
    def validate_subscription(subscriptions)
      schema_path = Pathname.new('lib/webhooks/subscriptions_schema.json')
      schemer_formats = {
        'valid_urls' => ->(urls, _schema_info) { validate_urls(urls) },
        'valid_events' => ->(subscription, _schema_info) { validate_events(subscription) }

      }
      schemer = JSONSchemer.schema(schema_path, formats: schemer_formats)
      unless schemer.valid?(subscriptions)
        raise SchemaValidationErrors, ["Invalid subscription! Body must match the included example\n#{SUBSCRIPTION_EX}"]
      end

      subscriptions
    end

    def validate_events(subscriptions)
      events = subscriptions.select { |s| s.key?('event') }.map { |s| s['event'] }
      raise SchemaValidationErrors, ["Duplicate Event(s) submitted! #{events}"] if Set.new(events).size != events.length

      api_names = subscriptions.select { |s| s.key?('event') }.map do |s|
        Webhooks::Utilities.event_to_api_name[s['event']]
      end
      if Set.new(api_names).size > 1
        raise SchemaValidationErrors, ["Subscription cannot span multiple APIs! #{api_names}"]
      end

      unsupported_events = events - Webhooks::Utilities.supported_events
      if unsupported_events.length.positive?
        raise SchemaValidationErrors, ["Invalid Event(s) submitted! #{unsupported_events}"]
      end

      true
    end

    def validate_url(url)
      begin
        uri = URI(url)
      rescue URI::InvalidURIError
        raise SchemaValidationErrors, ["Invalid subscription! URI does not parse: #{url}"]
      end
      https = uri.scheme.eql? 'https'
      if !https && Settings.webhooks.require_https
        raise SchemaValidationErrors, ["Invalid subscription! URL #{url} must be https!"]
      end

      true
    end

    def validate_urls(urls)
      valid = true
      urls.each do |url|
        valid &= validate_url(url)
      end
      valid
    end

    # rubocop:disable Lint/UnderscorePrefixedVariableName
    # Validates a maintenance request for a consumer declaring a URL under maintenance
    def validate_maintenance(maint_hash, consumer_id)
      api_name = maint_hash['api_name']
      schema_path = Pathname.new('lib/webhooks/maintenance_schema.json')
      schemer_formats = {
        'valid_api_name' => ->(_api_name, _schema_info) { Webhooks::Utilities.api_registered?(_api_name) },
        'valid_url' => ->(url, _schema_info) { url_subscribed?(url, consumer_id, api_name) }
      }
      schemer = JSONSchemer.schema(schema_path, formats: schemer_formats)
      unless schemer.valid?(maint_hash)
        raise SchemaValidationErrors,
              ["Invalid maintenance body! It must match the included example\n#{MAINTENANCE_EX}"]
      end
      maint_hash
    end
    # rubocop:enable Lint/UnderscorePrefixedVariableName

    def url_subscribed?(url, consumer_id, api_name)
      subscription = Webhooks::Subscription.where(api_name: api_name, consumer_id: consumer_id)&.first

      unless subscription
        raise SchemaValidationErrors, ["Subscription for the given api_name does not exist! api_name: #{api_name}"]
      end

      subscribed_urls = subscription.events['subscriptions'].map { |sub| sub['urls'] }.flatten
      if subscribed_urls.include?(url)
        true
      else
        raise SchemaValidationErrors, ["The provided URL is not subscribed to the given api_name! URL: #{url}"]
      end
    end
  end
end
# rubocop:enable ThreadSafety/InstanceVariableInClassMethod
# rubocop:enable Metrics/ModuleLength

require './lib/webhooks/registrations'
# Rails.env = 'test'
unless Rails.env.test?
  Webhooks::Utilities.supported_events.freeze
  Webhooks::Utilities.event_to_api_name.freeze
  Webhooks::Utilities.api_name_to_time_block.freeze
  Webhooks::Utilities.api_name_to_retries.freeze
end
