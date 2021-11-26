# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisabilityCompensationFastTrackJob, type: :worker do
  subject { described_class }

  before do
    Sidekiq::Worker.clear_all
  end

  let!(:user) { FactoryBot.create(:disabilities_compensation_user, icn: '2000163') }
  # let!(:account) { FactoryBot.create(:account, icn: user.icn, idme_uuid: user.uuid) }
  let(:icn_for_user_without_hypertension) { 17000151 } #TODO this icn is for someone with hypertension :-(
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

  describe '#perform', :vcr  do
    context 'success' do
      context 'the claim is NOT for hypertension' do
        it 'does returns from the class and does NOT continue' do
          #TODO the sample icn includes active hypertention :-( we need one without.
          expect(HypertensionObservationData).not_to receive(:new)
          subject.new.perform(icn_for_user_without_hypertension, user_full_name)
        end
      end

      context 'the claim IS for hypertension' do
        it 'calls #new on Lighthouse::ClinicalHealth::Client' do
          expect(Lighthouse::VeteransHealth::Client).to receive(:new).with(user.icn)
          DisabilityCompensationFastTrackJob.new.perform(submission.id, user_full_name)
        end

        it 'generates a pdf' do
          #TODO test the content of the PDF Generator in a unit spec
          expect(HypertensionPDFGenerator).to receive(:new).with(user_full_name, "", "", Date.today)
          DisabilityCompensationFastTrackJob.new.perform(submission.id, user_full_name)
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
