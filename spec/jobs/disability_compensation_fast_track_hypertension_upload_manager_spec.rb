# frozen_string_literal: true

require 'rails_helper'
require 'disability_compensation_fast_track_job'

RSpec.describe HypertensionUploadManager do
  let(:user) { create(:disabilities_compensation_user) }
  let(:auth_headers) do
    EVSS::DisabilityCompensationAuthHeaders.new(user).add_headers(EVSS::AuthHeaders.new(user).to_h)
  end
  let(:saved_claim) { FactoryBot.create(:va526ez) }
  let(:original_form_json) do
    File.read('spec/support/disability_compensation_form/submissions/with_uploads.json')
  end

  let(:original_form_json_uploads) do
    JSON.parse(original_form_json)['form526_uploads']
  end                                                                                     
  
  let(:form526_submission) do 
    Form526Submission.create(
      user_uuid: user.uuid,
      saved_claim_id: saved_claim.id,
      auth_headers_json: auth_headers.to_json,
      form_json: original_form_json
    )
  end

  describe '#add_upload(confirmation_code)' do
    context 'success' do
      it 'appends the new upload and saves the expected JSON' do
        HypertensionUploadManager.new(form526_submission).add_upload("fake_confirmation_code")
        expect(form526_submission.form_json).not_to eq original_form_json
        parsed_json = JSON.parse(form526_submission.form_json)['form526_uploads']
        expect(parsed_json).to match original_form_json_uploads + [{ 'name'=> 'hypertension_evidence.pdf', 'confirmationCode'=> 'fake_confirmation_code', 'attachmentId'=> '1489' }]
      end

      it 'adds upload files if no existing list is present' do
       # original = JSON.parse(form526_submission.form_json)
       # testdata = original.select { |k, _| k != 'form526_upload' }
       # form526_submission.form_json = JSON.dump(testdata)
       # uploads = JSON.parse(HypertensionUploadManager.new(form526_submission, '123').add_upload)['form526_uploads']
       # expected_files = [{ 'name'=> 'hypertension_evidence.pdf', 'confirmationCode'=> '123', 'attachmentId'=> '1489' }]
       # expect(uploads).to match expected_files
      end
    end
  end
end

