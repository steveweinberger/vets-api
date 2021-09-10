# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisabilityCompensationFastTrackJob, type: :job do
  subject { described_class }

  before do
    Sidekiq::Worker.clear_all
  end

  let(:user) { FactoryBot.create(:user, :loa3) }
  let!(:account) { FactoryBot.create(:account, icn: user.icn, idme_uuid: user.uuid) }
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

  describe 'perform' do
    it 'soemthing' do
      VCR.use_cassette('lighthouse/clinical_health/condition_success') do
        subject.perform_async(submission.id)
        described_class.drain
      end
    end
  end
end
