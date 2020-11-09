# frozen_string_literal: true

module V0
  module Ask
    class InquiryDocumentsController < ApplicationController
      skip_before_action(:authenticate)

      def create
        attachment = klass.new(form_id: form_id)
        # add the file after so that we have a form_id and guid for the uploader to use
        attachment.file = params['file']
        raise Common::Exceptions::ValidationErrors, attachment unless attachment.valid?

        attachment.save
        render json: attachment
      end

      private

      def klass
        case form_id
        when '0873'
          ::PersistentAttachments::InquiryDocument
        end
      end

      def form_id
        params[:form_id].upcase
      end
    end
  end
end
