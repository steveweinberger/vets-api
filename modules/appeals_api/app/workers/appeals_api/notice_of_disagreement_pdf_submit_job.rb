# frozen_string_literal: true

require 'sidekiq'
require 'appeals_api/upload_error'
require 'appeals_api/nod_pdf_submit_handler'
require 'central_mail/utilities'
require 'central_mail/service'
require 'pdf_info'
require 'sidekiq/monitored_worker'

module AppealsApi
  class NoticeOfDisagreementPdfSubmitJob
    include Sidekiq::Worker
    include Sidekiq::MonitoredWorker
    include CentralMail::Utilities
    include AppealsApi::CharacterUtilities

    def perform(appeal_id, version = 'V1', handler:, appeal_klass:)
      notice_of_disagreement = handler.new(appeal_klass.find(appeal_id))

      begin
        stamped_pdf = PdfConstruction::Generator.new(notice_of_disagreement, version: version).generate
        notice_of_disagreement.update_status!(status: 'submitting')
        upload_to_central_mail(notice_of_disagreement, stamped_pdf)
        File.delete(stamped_pdf) if File.exist?(stamped_pdf)
      rescue AppealsApi::UploadError => e
        handle_upload_error(notice_of_disagreement, e)
      rescue => e
        notice_of_disagreement.update_status!(status: 'error', code: e.class.to_s, detail: e.message)
        Rails.logger.error("#{self.class} error: #{e}")
        raise
      end
    end

    def retry_limits_for_notification
      [2, 5, 6, 10, 14, 17, 20]
    end

    def notify(retry_params)
      AppealsApi::Slack::Messager.new(retry_params, notification_type: :error_retry).notify!
    end

    private

    def upload_to_central_mail(notice_of_disagreement, pdf_path)
      metadata = notice_of_disagreement.metadata(pdf_path)
      body = { 'metadata' => metadata.to_json,
               'document' => to_faraday_upload(pdf_path, notice_of_disagreement.pdf_file_name) }
      process_response(CentralMail::Service.new.upload(body), notice_of_disagreement, metadata)
    end

    def process_response(response, notice_of_disagreement, metadata)
      if response.success? || response.body.match?(NON_FAILING_ERROR_REGEX)
        notice_of_disagreement.update_status!(status: 'submitted')
        log_submission(notice_of_disagreement, metadata)
      else
        map_error(response.status, response.body, AppealsApi::UploadError)
      end
    end

    def handle_upload_error(notice_of_disagreement, e)
      log_upload_error(notice_of_disagreement, e)
      notice_of_disagreement.update(status: 'error', code: e.code, detail: e.detail)

      if e.code == 'DOC201' || e.code == 'DOC202'
        notify(
          {
            'class' => self.class.name,
            'args' => [notice_of_disagreement.id],
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

    def log_upload_error(notice_of_disagreement, e)
      Rails.logger.error("#{notice_of_disagreement.class.to_s.gsub('::', ' ')}: Submission failure",
                         'source' => notice_of_disagreement.consumer_name,
                         'consumer_id' => notice_of_disagreement.consumer_id,
                         'consumer_username' => notice_of_disagreement.consumer_name,
                         'uuid' => notice_of_disagreement.id,
                         'code' => e.code,
                         'detail' => e.detail)
    end
  end
end
