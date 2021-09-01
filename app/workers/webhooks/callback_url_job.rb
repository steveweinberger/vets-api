# frozen_string_literal: true

module Webhooks
  class CallbackUrlJob
    include Sidekiq::Worker
    include Webhooks
    include Webhooks::Utilities

    MAX_BODY_LENGTH = 500 # denotes the how large of a body from the client url we record in our db.

    # rubocop:disable Rails/SkipsModelValidations
    def perform(url, ids, max_retries)
      @url = url
      @ids = ids
      @max_retries = max_retries
      @notifications = Webhooks::Notification.where(id: ids).order(:event, :api_guid, :created_at).all
      @subscription = @notifications.first.webhooks_subscription
      subscribed_urls = @subscription.get_notification_urls

      if subscribed_urls.include? @url
        if run_later? || under_maintenance?
          # wait to run later based on the api failure schedule so update the processing column to nil
          # for these ids so they will be checked on the next run
          Notification.where(id: @ids).update_all(processing: nil)
        else
          @msg = { 'api_name' => @subscription.api_name, 'timestamp' => Time.current.to_i, 'notifications' => [] }
          @notifications.each do |notification|
            @msg['notifications'] << notification.msg
          end
          notify
        end
      else
        Rails.logger.debug("Webhooks::CallbackUrlJob Sealing off de-registered callback url #{url} for ids #{ids}")
        arg = { notifications: @notifications, success: false,
                response: FINAL_ATTEMPT_URL_REMOVED, max_retries: -1 }
        record_attempt(arg)
      end
    end
    # rubocop:enable Rails/SkipsModelValidations

    private

    # rubocop:disable Metrics/MethodLength
    def notify
      @response = Faraday.post(@url, @msg.to_json, 'Content-Type' => 'application/json')
    rescue Faraday::ClientError, Faraday::Error => e
      Rails.logger.error("Webhooks::CallbackUrlJob Error in CallbackUrlJob #{e.message}", e)
      @response = e
    rescue => e
      Rails.logger.error("Webhooks::CallbackUrlJob unexpected Error in CallbackUrlJob #{e.message}", e)
      @response = e
    ensure
      Webhooks::Subscription.clean_subscription(@subscription.api_name, @subscription.consumer_id) do |locked_sub|
        successful = false
        if @response.respond_to? :success?
          successful = @response.success?
          attempt_response = { NotificationAttempt::RESPONSE_STATUS => @response.status,
                               NotificationAttempt::RESPONSE_BODY => @response.body[0...MAX_BODY_LENGTH] }
        else
          attempt_response = { NotificationAttempt::RESPONSE_EXCEPTION =>
                                   { NotificationAttempt::RESPONSE_EXCEPTION_TYPE => @response.class.to_s,
                                     NotificationAttempt::RESPONSE_EXCEPTION_MESSAGE => @response.message } }
        end

        args = { notifications: @notifications, success: successful,
                 response: attempt_response, max_retries: @max_retries }
        record_attempt(args)
        record_attempt_metadata(@url, successful, attempt_response, locked_sub)

        if locked_sub.blocked_callback_urls.include?(@url)
          args = { notifications: @notifications, success: false,
                   response: FINAL_ATTEMPT_BLOCKED, max_retries: -1 }
          record_attempt(args)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Style/RescueModifier
    def run_later?
      metadata = @subscription.metadata
      run_after_epoch = metadata[@url][Subscription::FAILURE_KEY][Subscription::RUN_AFTER_KEY].to_i rescue 0
      run_after_epoch > Time.current.to_i
    end
    # rubocop:enable Style/RescueModifier

    # rubocop:disable Style/RescueModifier
    def under_maintenance?
      @subscription.metadata[@url][Subscription::MAINTENANCE_KEY][Subscription::UNDER_MAINT_KEY] rescue false
    end
    # rubocop:enable Style/RescueModifier

    def seal_off_blocked?
      @subscription.blocked_callback_urls.include? @url
    end
  end
end
