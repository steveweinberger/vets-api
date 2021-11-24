# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisabilityCompensationFastTrackJob, type: :worker do
  subject { described_class }

  before do
    Sidekiq::Worker.clear_all
  end

  let!(:user) { FactoryBot.create(:disabilities_compensation_user) }
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

  describe '#perform' do
    context 'success' do
      context 'the claim is NOT for hypertension' do
        it 'does nothing' do
          raise 'not implemented'
        end
      end

      context 'the claim IS for hypertension' do
        it 'calls #new on Lighthouse::ClinicalHealth::Client' do
          raise 'not implemented'
        end

        it 'parses the response from Lighthouse::ClinicalHelth::Client' do
          raise 'not implemented'
        end

        it 'generates a pdf' do
          raise 'not implemented'
        end

        it 'includes the neccesary information in the pdf' do
          raise 'not implemented'
        end

        it 'posts the pdf to S3 in the expected location' do
          raise 'not implemented'
        end
      end

      context 'failure' do
        it 'raises a helpful error' do
          allow(Lighthouse::VeteransHealth::Client).to receive(:new).and_return nil
          subject.perform_async(submission.id)
          raise 'not implemented'
        end
      end
    end
  end

  describe '#hypertension?' do
    let(:condition_response) do
      double(
        'condition response',
        body: HashWithIndifferentAccess.new(
          { 'entry':
            [{ 'resource': { 'code': { 'text': text_string } } }] }
        )
      )
    end

    context 'when hypertension is a condition assigned to the user' do
      let(:text_string) { 'Hypertension' }

      it 'returns true' do
        expect(subject.new.hypertension?(condition_response)).to eq true
      end
    end

    context 'when hypertension is NOT a condition assigned to the user' do
      let(:text_string) { 'something' }

      it 'returns false' do
        expect(subject.new.hypertension?(condition_response)).to eq false
      end
    end
  end
end
