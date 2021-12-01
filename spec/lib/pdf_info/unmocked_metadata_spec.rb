# frozen_string_literal: true

require 'rails_helper'

require 'pdf_info'

describe PdfInfo::Metadata do

  let(:docusign_pdf) {'./spec/fixtures/pdf_info/VA21-22-kostya-signed.pdf'}

  describe '::read' do
    context 'reading a pdf' do
      it 'parses files pdf files using an updated version of poppler utils' do
        with_settings(Settings.binaries, pdfinfo: 'pdfinfo') do
          expect {PdfInfo::Metadata.read(docusign_pdf)}.to raise_error(PdfInfo::MetadataReadError)
        end
        with_settings(Settings.binaries, pdfinfo: '/srv/vets-api/src/util/bin/pdfinfo') do
          parts_content = PdfInfo::Metadata.read(docusign_pdf)
          expect(parts_content['Metadata Stream'].eql?('yes')).to be_truthy
        end
      end
    end
  end
end
