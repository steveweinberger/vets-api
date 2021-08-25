# frozen_string_literal: true

module Webhooks
  class CallbackUrlJob
    include Sidekiq::Worker
    include Webhooks

    MAX_BODY_LENGTH = 500 # denotes the how large of a body from the client url we record in our db.
    SPOOF = Struct.new(:success?, :status, :body)

    def perform(url, ids, max_retries)
      @url = url
      @ids = ids
      @max_retries = max_retries
      @subscription = Webhooks::Notification.find_by(id: @ids.first).webhooks_subscription

      if run_later?
        # wait to run later based on the api failure schedule so update the processing column to nil
        # for these ids so they will be checked on the next run
        Notification.where(id: @ids).update_all(processing: nil)
      else
        @msg = {'api_name' => @subscription.api_name, 'notifications' => []}
        Webhooks::Notification.where(id: ids).order(:event, :api_guid, :created_at).each do |notification|
          @msg['notifications'] << notification.msg
        end
        Rails.logger.debug "Webhooks::CallbackUrlJob Notifying on callback url #{url} for ids #{ids} with msg #{@msg}"
        notify
      end
    end

    private

    def run_later?
      metadata = @subscription.metadata
      run_after_epoch = metadata[@url][Subscription::FAILURE_KEY][Subscription::RUN_AFTER].to_i rescue 0
      run_after_epoch > Time.current.to_i
    end

    def seal_off_blocked?
      @subscription.blocked_callback_urls.include? @url
    end

    def exception_testing
      should_fail = @redis.get('faraday_failure')
      unless should_fail.to_s.empty?
        raise eval(should_fail)
        #Faraday::ClientError.new("I am bad")
        # @redis.set('faraday_failure', %q(Faraday::ClientError.new("I am bad")))
        # @redis.set('faraday_failure', %q(Faraday::Error.new("I am very bad")))
        # @redis.set('faraday_failure', nil))
        # @redis.set('hook_failure', 'yup')
        # @redis.set('hook_status',503)
        # @redis.set('hook_failure',nil)
      end
    end

    def notify
      @redis = Redis.new(host: 'redis', port: 6379)
      exception_testing
      should_fail = @redis.get('hook_failure')
      if !should_fail.to_s.empty?
        status = @redis.get('hook_status')
        @response = SPOOF.new(false, status.to_i, 'billy')
      else
        @response = Faraday.post(@url, @msg.to_json, 'Content-Type' => 'application/json')
      end
    rescue Faraday::ClientError, Faraday::Error => e
      Rails.logger.error("Webhooks::CallbackUrlJob Error in CallbackUrlJob #{e.message}", e)
      @response = e
    rescue => e
      Rails.logger.error("Webhooks::CallbackUrlJob unexpected Error in CallbackUrlJob #{e.message}", e)
      @response = e
    ensure
      record_attempt
    end

    def record_attempt
      attempt_response = nil
      ActiveRecord::Base.transaction do
        @successful = false
        if @response.respond_to? :success?
          @successful = @response.success?
          attempt_response = {NotificationAttempt::RESPONSE_STATUS => @response.status,
                              NotificationAttempt::RESPONSE_BODY => @response.body[0...MAX_BODY_LENGTH]}
        else
          attempt_response = {NotificationAttempt::RESPONSE_EXCEPTION =>
                                  {NotificationAttempt::RESPONSE_EXCEPTION_TYPE => @response.class.to_s,
                                   NotificationAttempt::RESPONSE_EXCEPTION_MESSAGE => @response.message}}
        end

        # create the notification attempt record
        attempt = create_attempt(attempt_response)
        # write an association record tied to each notification used in this attempt
        notifications = []
        Webhooks::Notification.where(id: @ids).each do |notification|
          create_attempt_assoc(notification, attempt)

          # seal off the attempt if we received a successful response or hit our max retry limit
          if attempt.success? || notification.webhooks_notification_attempts.count >= @max_retries
            notification.final_attempt_id = attempt.id
          end

          notification.processing = nil
          notifications << notification
        end
        record_attempt_metadata(attempt_response, notifications)
        notifications.each(&:save!)
      end
    end

    def record_attempt_metadata(attempt_response, notifications)
      @subscription.with_lock do
        metadata = @subscription.metadata
        metadata[@url] ||= {}

        if @successful
          metadata[@url] = {} # todo preserve maintenance
        else
          metadata[@url][Subscription::FAILURE_KEY] ||= {}
          status_code = nil
          if attempt_response.has_key? NotificationAttempt::RESPONSE_EXCEPTION
            status_code =
                attempt_response[NotificationAttempt::RESPONSE_EXCEPTION][NotificationAttempt::RESPONSE_EXCEPTION_TYPE]
          else
            status_code = attempt_response[NotificationAttempt::RESPONSE_STATUS]
          end
          metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS] ||= {}
          metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS]['total'] ||= 0
          metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS]['total'] += 1
          metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS][status_code.to_s] ||= 0
          metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS][status_code.to_s] += 1

          # calculate next time via block and record
          failure_block = Utilities.api_name_to_failure_block[@subscription.api_name]
          next_time = 1.hour.from_now
          begin
            next_time = failure_block.call(metadata[@url][Subscription::FAILURE_KEY][NotificationAttempt::RESPONSE_STATUS])
          rescue => e
            Rails.logger.error("For #{@subscription.api_name} the webhook failure block failed to execute.", e)
          end
          # todo wrap in handlers and default to a time if a bad time is given (say one hour)
          metadata[@url][Subscription::FAILURE_KEY][Subscription::RUN_AFTER] = next_time.to_i
        end
        @subscription.metadata = metadata
        @subscription.save!
        if seal_off_blocked?
          attempt = Webhooks::Utilities.create_blocked_attempt(@url)
          notifications.each do |n|
            n.final_attempt_id = attempt.id
            create_attempt_assoc(n, attempt)
          end
        end
      end
    end

    def create_attempt(response)
      attempt = Webhooks::NotificationAttempt.new do |a|
        a.success = @successful
        a.response = response
        a.callback_url = @url
      end
      attempt.save!
      attempt
    end

    def create_attempt_assoc(notification, attempt)
      attempt_assoc = Webhooks::NotificationAttemptAssoc.new do |naa|
        naa.webhooks_notification_id = notification.id
        naa.webhooks_notification_attempt_id = attempt.id
      end
      attempt_assoc.save!
      attempt_assoc
    end
  end
end
