# frozen_string_literal: true

require 'sidekiq'
require 'appeals_api/upload_error'
require 'appeals_api/hlr_pdf_submit_handler'
require 'central_mail/utilities'
require 'central_mail/service'
require 'pdf_info'
require 'sidekiq/monitored_worker'

module AppealsApi
  class HigherLevelReviewPdfSubmitJob
    include Sidekiq::Worker
    include Sidekiq::MonitoredWorker
    include CentralMail::Utilities
    include AppealsApi::CharacterUtilities

    # Retry for ~7 days
    sidekiq_options retry: 20

    def perform(higher_level_review_id, version = 'V1', handler:, appeal_klass:)
      higher_level_review = handler.new(appeal_klass.find(higher_level_review_id))

      begin
        stamped_pdf = AppealsApi::PdfConstruction::Generator.new(higher_level_review, version: version).generate
        higher_level_review.update_status!(status: 'submitting')
        upload_to_central_mail(higher_level_review, stamped_pdf)
        File.delete(stamped_pdf) if File.exist?(stamped_pdf)
      rescue AppealsApi::UploadError => e
        handle_upload_error(higher_level_review, e)
      rescue => e
        higher_level_review.update_status!(status: 'error', code: e.class.to_s, detail: e.message)
        Rails.logger.error("#{self.class} error: #{e}")
        raise
      end
    end

    def retry_limits_for_notification
      # Alert @ 1m, 10m, 30m, 4h, 1d, 3d, and 7d
      [2, 5, 6, 10, 14, 17, 20]
    end

    def notify(retry_params)
      AppealsApi::Slack::Messager.new(retry_params, notification_type: :error_retry).notify!
    end

    private

    def upload_to_central_mail(higher_level_review, pdf_path)
      metadata = higher_level_review.metadata(pdf_path)
      body = { 'metadata' => metadata.to_json,
               'document' => to_faraday_upload(pdf_path, higher_level_review.pdf_file_name) }
      process_response(CentralMail::Service.new.upload(body), higher_level_review, metadata)
    end

    def process_response(response, higher_level_review, metadata)
      if response.success? || response.body.match?(NON_FAILING_ERROR_REGEX)
        higher_level_review.update_status!(status: 'submitted')
        log_submission(higher_level_review, metadata)
      else
        map_error(response.status, response.body, AppealsApi::UploadError)
      end
    end

    def log_upload_error(higher_level_review, e)
      Rails.logger.error("#{higher_level_review.class.to_s.gsub('::', ' ')}: Submission failure",
                         'source' => higher_level_review.consumer_name,
                         'consumer_id' => higher_level_review.consumer_id,
                         'consumer_username' => higher_level_review.consumer_name,
                         'uuid' => higher_level_review.id,
                         'code' => e.code,
                         'detail' => e.detail)
    end

    def handle_upload_error(higher_level_review, e)
      log_upload_error(higher_level_review, e)
      higher_level_review.update(status: 'error', code: e.code, detail: e.detail)

      if e.code == 'DOC201' || e.code == 'DOC202'
        notify(
          {
            'class' => self.class.name,
            'args' => [higher_level_review.id],
            'error_class' => e.code,
            'error_message' => e.detail,
            'failed_at' => Time.zone.now
          }
        )
      else
        # allow sidekiq to retry immediately
        raise
      end
    end
  end
end
