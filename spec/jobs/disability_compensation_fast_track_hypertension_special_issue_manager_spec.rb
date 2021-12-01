# frozen_string_literal: true

require 'rails_helper'
require 'disability_compensation_fast_track_job'

RSpec.describe HypertensionSpecialIssueManager do
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
    File.read('spec/support/disability_compensation_form/submissions/only_526_hypertension.json')
  end

  describe '#add_special_issue' do
    it 'matches the email address' do
      expect(JSON.parse(form526_submission.form_json)['form526']['form526']['veteran']['emailAddress']).to match "test@email.com"
    end

    it 'matches the email address after manipulation' do
      HypertensionSpecialIssueManager.new(form526_submission).add_special_issue
      expect(JSON.parse(form526_submission.form_json)['form526']['form526']['veteran']['emailAddress']).to match "test@email.com"
    end

    it 'adds rrd to the disabilities list' do
      HypertensionSpecialIssueManager.new(form526_submission).add_special_issue
      disabilities = JSON.parse(form526_submission.form_json)['form526']['form526']['disabilities']
      filtered = disabilities.filter { |item| item['diagnosticCode'] == 7101 }
      expect(filtered[0]['specialIssues']).to match [{'code'=> 'RRD', 'name'=> 'Rapid Ready for Decision'}]
    end

    it 'adds rrd to each relevant item in the disabilities list' do
      HypertensionSpecialIssueManager.new(form526_submission).add_special_issue
      disabilities = JSON.parse(form526_submission.form_json)['form526']['form526']['disabilities']
      rrd_hash = { 'code'=> 'RRD', 'name'=> 'Rapid Ready for Decision'}
      filtered = disabilities.filter { |item| item['diagnosticCode'] == 7101 }
      expect(filtered).to all( include 'specialIssues')
      expect(filtered.any? { |el| el['specialIssues'].include? rrd_hash }).to be true
    end

    it 'adds rrd to the disabilities list only once' do
      HypertensionSpecialIssueManager.new(form526_submission).add_special_issue
      disabilities = JSON.parse(form526_submission.form_json)['form526']['form526']['disabilities']
      filtered = disabilities.filter { |item| item['diagnosticCode'] == 7101 }
      expect(filtered[0]['specialIssues']).to match [{'code'=> 'RRD', 'name'=> 'Rapid Ready for Decision'}]
      jform = JSON.parse(form526_submission.form_json)
      jform['form526']['form526']['disabilities'] = disabilities
      form526_submission.form_json = JSON.dump(jform)

      HypertensionSpecialIssueManager.new(form526_submission).add_special_issue
      second_pass = JSON.parse(form526_submission.form_json)['form526']['form526']['disabilities']
      filtered = second_pass.filter { |item| item['diagnosticCode'] == 7101 }
      expect(filtered[0]['specialIssues']).to match [{'code'=> 'RRD', 'name'=> 'Rapid Ready for Decision'}]
    end

    # TODO: need tests for cases where more than one disability is present.
    # TODO: need tests for cases where hypertension is not one of the disabilities.
    # TODO: maybe need tests for cases where hypertension is present and already has a non-RRD special issue attached to it.
  end
end
