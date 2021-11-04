# frozen_string_literal: true

require 'prawn'
require 'lighthouse/clinical_health/client'

class DisabilityCompensationFastTrackJob
  include Sidekiq::Worker
  extend SentryLogging
  sidekiq_options retry: 14

  def perform(form526_submission_id)
    submission = Form526Submission.find(form526_submission_id)
    icn = Account.where(idme_uuid: submission.user_uuid).first.icn

    client = Lighthouse::ClinicalHealth::Client.new
    condition_repsonse = client.get_condition(icn)
    pdf_body = generate_pdf(condition_repsonse)

    client = EVSS::DocumentsService.new(submission.auth_headers)
    client.upload(pdf_body, create_document_data(upload_data))
  end

  def generate_pdf(_condition_repsonse)
    # Prawn documentation - https://prawnpdf.org/manual.pdf
    # todo: do something with lighthouse response to put in PDF
    pdf = Prawn::Document.new
    pdf.text 'Hello World!'
    pdf.define_grid(columns: 5, rows: 8, gutter: 10)
    pdf.render
  end

  def create_document_data(submission)
    # 'L048' => 'Medical Treatment Record - Government Facility',
    EVSSClaimDocument.new(
      evss_claim_id: submission.submitted_claim_id,
      file_name: 'hypertension_evidence.pdf',
      tracked_item_id: nil,
      document_type: 'L048'
    )
  end
end
