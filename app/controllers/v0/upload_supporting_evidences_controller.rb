# frozen_string_literal: true

module V0
  class UploadSupportingEvidencesController < VetsApiController
    include FormAttachmentCreate
    FORM_ATTACHMENT_MODEL = SupportingEvidenceAttachment
  end
end
