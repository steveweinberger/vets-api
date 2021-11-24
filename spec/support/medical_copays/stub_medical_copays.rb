# frozen_string_literal: true

def stub_medical_copays(method)
  let(:content) { File.read('spec/fixtures/medical_copays/index.json') }
  if method == :index
    before do
      allow_any_instance_of(MedicalCopays::VBS::Service).to receive(:get_copays).and_return(content)
    end
  end
  if method == :get_pdf_statement_by_id
    let(:document_id) { '{93631483-E9F9-44AA-BB55-3552376400D8}' }
    let(:content) { File.read('spec/fixtures/files/error_message.txt') }

    before do
      allow_any_instance_of(MedicalCopays::VBS::Service).to receive(:get_pdf_statement_by_id).and_return(content)
      expect(MedicalCopays::VBS::Service.get_pdf_statement_by_id).to receive(:file_name).with(document_id).and_return('staement.pdf')
    end
  else
    let(:get_pdf_by_id_res) { get_fixture('medical_copays/pdf_payload') }

    before do
      expect(MedicalCopays::VBS::Service.get_pdf_statement_by_id).to receive(:list_letters).and_return(
        get_pdf_by_id_res
      )
    end
  end
end
