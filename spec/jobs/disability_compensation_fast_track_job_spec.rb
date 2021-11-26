# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisabilityCompensationFastTrackJob, type: :worker do
  subject { described_class }

  before do
    Sidekiq::Worker.clear_all
  end

  let!(:user) { FactoryBot.create(:disabilities_compensation_user, icn: '2000163') }
  # let!(:account) { FactoryBot.create(:account, icn: user.icn, idme_uuid: user.uuid) }
  let(:auth_headers) do
    EVSS::DisabilityCompensationAuthHeaders.new(user).add_headers(EVSS::AuthHeaders.new(user).to_h)
  end
  let(:saved_claim) { FactoryBot.create(:va526ez) }
  let(:submission) do
    create(:form526_submission, :with_uploads,
           user_uuid: user.uuid,
           auth_headers_json: auth_headers.to_json,
           saved_claim_id: saved_claim.id,
           submitted_claim_id: '600130094')
  end

  let(:user_full_name) { user.first_name + user.last_name }
  let(:mocked_observation_data) do
    [{:issued=>"{Date.today.year}-03-23T01:15:52Z",
      :practitioner=>"DR. THOMAS359 REYNOLDS206 PHD",
      :organization=>"LYONS VA MEDICAL CENTER",
      :systolic=>{"code"=>"8480-6", "display"=>"Systolic blood pressure", "value"=>115.0, "unit"=>"mm[Hg]"},
      :diastolic=>{"code"=>"8462-4", "display"=>"Diastolic blood pressure", "value"=>87.0, "unit"=>"mm[Hg]"}}]
  end

  describe '#perform', :vcr  do
    context 'success' do
      context 'the claim is NOT for hypertension' do
        let(:icn_for_user_without_bp_reading_within_one_year) { 17000151 }
        let!(:user) do
          FactoryBot.create(:disabilities_compensation_user, icn: icn_for_user_without_bp_reading_within_one_year)
        end
        let!(:submission_for_user_wo_bp) do
          create(:form526_submission, :with_uploads,
                 user_uuid: user.uuid,                           
                 auth_headers_json: auth_headers.to_json,
                 saved_claim_id: saved_claim.id,                 
                 submitted_claim_id: '600130094')                  
        end

        it 'returns from the class if the claim observations does NOT include bp readings from the past year' do
          expect(HypertensionMedicationRequestData).not_to receive(:new)
          subject.new.perform(submission_for_user_wo_bp.id, user_full_name)
        end
      end

      context 'the claim IS for hypertension', :vcr do
        before do
          #TODO the bp reading needs to be 1 year or less old so actual API data will not test if this code is working.
          allow_any_instance_of(HypertensionObservationData).to receive(:transform).and_return(mocked_observation_data)
        end

        it 'generates a pdf' do
          #TODO this doesn't work. The HypertensionPDFGenerator is being passed a name string but the class expects it to be an array that may or may not include suffix on line 219.
        end

        it 'calls new on EVSS::DocumentsService with the expected arguments' do
          expect(EVSS::DocumentsService).to receive(:new).with("")
          DisabilityCompensationFastTrackJob.new.perform(submission.id, user_full_name)
        end
      end

      context 'failure' do
        it 'raises a helpful error' do
          #maybe use this error from Michel's work: https://github.com/department-of-veterans-affairs/vets-api/pull/8494/files#diff-cdcaa26c5cfce0d1bda78201f27a4c6eb554d5d45ff50d92eec5f393d3d44f6dR110
          allow(Lighthouse::VeteransHealth::Client).to receive(:new).and_return nil
          subject.perform_async(submission.id)
          raise 'not implemented'
        end
      end
    end
  end
end
