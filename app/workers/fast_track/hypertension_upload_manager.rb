# frozen_string_literal: true

module FastTrack
  class HypertensionUploadManager
    attr_accessor :submission

    def initialize(submission)
      @submission = submission
    end

    def add_upload(confirmation_code)
      data = JSON.parse(submission.form_json)
      uploads = data['form526_uploads'] || []
      new_upload = {
        "name": 'VAMC_Hypertension_Rapid_Decision_Evidence.pdf',
        "confirmationCode": confirmation_code,
        "attachmentId": '1489'
      }
      uploads.append(new_upload)
      data['form526_uploads'] = uploads
      submission.update(form_json: JSON.dump(data))
      submission
    end

    def already_has_summary_file
      data = JSON.parse(submission.form_json)
      uploads = data['form526_uploads'] || []
      existing_summary = false
      uploads.each do |upload|
        existing_summary = true if upload['name'][0, 41] == 'VAMC_Hypertension_Rapid_Decision_Evidence'
      end
      existing_summary
    end

    def handle_attachment(pdf_body)
      existing_summary = already_has_summary_file
      unless existing_summary
        supporting_evidence_attachment = SupportingEvidenceAttachment.new
        file = FileIO.new(pdf_body, 'VAMC_Hypertension_Rapid_Decision_Evidence.pdf')
        supporting_evidence_attachment.set_file_data!(file)
        supporting_evidence_attachment.save!
        confirmation_code = supporting_evidence_attachment.guid

        form526_submission = add_upload(confirmation_code) unless confirmation_code.nil?
      end
      form526_submission
    end
  end

  class FileIO < StringIO
    def initialize(stream, filename)
      super(stream)
      @original_filename = filename
      @fast_track = true
      @content_type = 'application/pdf'
    end

    attr_reader :content_type, :original_filename, :fast_track
  end
end
