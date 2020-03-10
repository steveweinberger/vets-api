# frozen_string_literal: true

module V0
  class HcaAttachmentsController < VetsApiController
    include FormAttachmentCreate

    FORM_ATTACHMENT_MODEL = HcaAttachment
  end
end
