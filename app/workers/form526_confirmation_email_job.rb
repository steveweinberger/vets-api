# frozen_string_literal: true

require 'notifications/client'

class Form526ConfirmationEmailJob
  include Sidekiq::Worker
  sidekiq_options expires_in: 1.day

  STATSD_ERROR_NAME = 'worker.form526_confirmation_email.error'

  def perform(id, email, submitted_claim_id, updated_at, first_name, last_name)
    @notify_client ||= Notifications::Client.new(
      Settings.vanotify.api_key,
      Settings.vanotify.client_url
    )
    @notify_client.send_email(
      email_address: email,
      template_id: Settings.vanotify.template_id.form526_confirmation_email,
      personalisation: {
        claim_id: submitted_claim_id,
        date_submitted: updated_at.strftime('%B %-d, %Y'),
        first_name: first_name,
        last_name: last_name
      }
    )
  rescue => e
    Rails.logger.error(
      "Error performing Form526ConfirmationEmailJob: #{e.message}",
      submission_id: id
    )
    StatsD.increment(STATSD_ERROR_NAME)
  end
end
