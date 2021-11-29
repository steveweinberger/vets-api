# frozen_string_literal: true

require 'rails_helper'
require 'disability_compensation_fast_track_job'

RSpec.describe HypertensionUploadManager do
  let(:form526_submission) do 
    Form526Submission.create(
      user_uuid: user.uuid,
      saved_claim_id: saved_claim.id,
      auth_headers_json: auth_headers.to_json,
      form_json: form_json
    )
  end

  let(:user) { create(:disabilities_compensation_user) }
  let(:auth_headers) do
    EVSS::DisabilityCompensationAuthHeaders.new(user).add_headers(EVSS::AuthHeaders.new(user).to_h)
  end
  let(:saved_claim) { FactoryBot.create(:va526ez) }
  let(:form_json) do
    File.read('spec/support/disability_compensation_form/submissions/with_uploads.json')
  end

  describe '#add_upload' do
    it 'matches the email address' do
      expect(JSON.parse(form526_submission.form_json)['form526']['form526']['veteran']['emailAddress']).to match "test@email.com"
    end

    it 'matches the email address after manipulation' do
      expect(JSON.parse(HypertensionUploadManager.new(form526_submission, '123').add_upload)['form526']['form526']['veteran']['emailAddress']).to match "test@email.com"
    end

    it 'adds the new upload to the files list' do
      existing_files = JSON.parse(form526_submission.form_json)['form526_uploads']
      uploads = JSON.parse(HypertensionUploadManager.new(form526_submission, '123').add_upload)['form526_uploads']
      expected_files = existing_files + [{ 'name'=> 'hypertension_evidence.pdf', 'confirmationCode'=> '123', 'attachmentId'=> '1489' }]
      expect(uploads).to match expected_files
    end

    it 'adds upload files if no existing list is present' do
      original = JSON.parse(form526_submission.form_json)
      testdata = original.select { |k, _| k != 'form526_upload' }
      form526_submission.form_json = JSON.dump(testdata)
      uploads = JSON.parse(HypertensionUploadManager.new(form526_submission, '123').add_upload)['form526_uploads']
      expected_files = [{ 'name'=> 'hypertension_evidence.pdf', 'confirmationCode'=> '123', 'attachmentId'=> '1489' }]
      expect(uploads).to match expected_files
    end

  end
end

