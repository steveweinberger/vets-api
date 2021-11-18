# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisabilityCompensationFastTrackJob, type: :job do
  subject { described_class }

  before do
    Sidekiq::Worker.clear_all
  end

  let!(:user) { FactoryBot.create(:user, :loa3) }
  #let!(:account) { FactoryBot.create(:account, icn: user.icn, idme_uuid: user.uuid) }
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
    #Once we have the logic for pinging lighthouse merged into our class, we should have our own cassette for the query in question 🤷<200d>♀️ OR do we KNOW that this 'lighthouse/clinical_health/condition_success' includes hypertension? 
    #
    #it 'soemthing' do
    #  VCR.use_cassette('lighthouse/clinical_health/condition_success') do
    #    subject.perform_async(submission.id)
    #    described_class.drain
    #  end
    #end

    context 'success' do
      context 'the claim is NOT for hypertension' do
        it 'does nothing' do
          subject.perform_async(submission.id)
          raise "not implemented"
        end
      end

      context 'the claim IS for hypertension' do
        it 'calls #new on Lighthouse::ClinicalHelth::Client' do
        end

        it 'parses the response from Lighthouse::ClinicalHelth::Client' do
          ########
        end

        it 'generates a pdf' do
          raise "not implemented"
        end

        it 'includes the neccesary information in the pdf' do
          raise "not implemented"
        end

        it 'calls #upload on EVSS::DocumentsService with the expected argumnets' do
          raise "not implemented"
        end
      end
    end

    context 'failure' do
      it 'raises a helpful error' do
        allow(Lighthouse::ClinicalHealth::Client).to receive(:new).and_return nil
        subject.perform_async(submission.id)
        raise "not implemented"
      end
    end
  end
end

RSpec.describe HypertensionObservationData do
  subject { described_class }

  let(:response) do
    client = Lighthouse::ClinicalHealth::Client.new
    # Using specific test ICN below:
    client.get_observations(2000163)
  end

  before(:all) do
    VCR.configure { |c| c.allow_http_connections_when_no_cassette = true }
  end

  after(:all) do
    VCR.configure { |c| c.allow_http_connections_when_no_cassette = false }
  end



  describe "#transform" do
    VCR.use_cassette('lighthouse/clinical_health/condition_success') do
      it "returns the expected hash" do
        expect(described_class.new(response).transform)
          .to eq(
[{ issued: "2009-03-23T01:15:52Z", practitioner: "DR. THOMAS359 REYNOLDS206 PHD", organization: "LYONS VA MEDICAL CENTER", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 115.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 87.0, "unit" => "mm[Hg]" } }, { issued: "2010-03-29T01:15:52Z", practitioner: "DR. JANE460 DOE922 MD", organization: "WASHINGTON VA MEDICAL CENTER", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 102.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 70.0, "unit" => "mm[Hg]" } }, { issued: "2011-04-04T01:15:52Z", organization: "NEW AMSTERDAM CBOC", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 137.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 86.0, "unit" => "mm[Hg]" } }, { issued: "2012-04-09T01:15:52Z", organization: "LYONS VA MEDICAL CENTER", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 124.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 80.0, "unit" => "mm[Hg]" } }, { issued: "2013-04-15T01:15:52Z", practitioner: "DR. JOHN248 SMITH811 MD", organization: "NEW AMSTERDAM CBOC", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 156.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 118.0, "unit" => "mm[Hg]" } }, { issued: "2014-04-21T01:15:52Z", practitioner: "DR. JANE460 DOE922 MD", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 192.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 93.0, "unit" => "mm[Hg]" } }, { issued: "2017-04-24T01:15:52Z", practitioner: "DR. JANE460 DOE922 MD", organization: "WASHINGTON VA MEDICAL CENTER", systolic: { "code" => "8480-6", "display" => "Systolic blood pressure", "value" => 153.0, "unit" => "mm[Hg]" }, diastolic: { "code" => "8462-4", "display" => "Diastolic blood pressure", "value" => 99.0, "unit" => "mm[Hg]" } }]
          )
      end
    end
  end
end
