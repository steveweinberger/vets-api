# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form1010cg::Service do
  let(:build_valid_claim_data) { -> { VetsJsonSchema::EXAMPLES['10-10CG'].clone } }

  describe '#submit_claim!' do
    it 'will raise a ValidationErrors when the provided claim is invalid' do
      claim = double

      # called when claim is passed to: raise Common::Exceptions::ValidationErrors
      expect(claim).to receive(:valid?).and_return(false)
      expect(claim).to receive(:empty?).and_return(true)
      expect(claim).to receive(:errors)

      expect do
        subject.submit_claim!(claim)
      end.to raise_error(Common::Exceptions::ValidationErrors)
    end

    it 'will build a CARMA::Models:Submission and send to CARMA' do
      expected = {
        carma_case_id: 'aB935000000A9GoCAK',
        submitted_at: DateTime.new,
        metadata: {
          veteran: { icn: '999V1000' },
          primaryCaregiver: { icn: '333V2000' }
        }
      }

      parsed_form = build_valid_claim_data.call
      claim = double(parsed_form: parsed_form)
      carma_submission = double

      expect(claim).to receive(:valid?).and_return(true)

      expect(CARMA::Models::Submission).to receive(:from_claim).with(claim).and_return(carma_submission)

      mvi_lookup_1 = double(status: 'OK', profile: double(icn: expected[:metadata][:veteran][:icn]))
      mvi_lookup_2 = double(status: 'OK', profile: double(icn: expected[:metadata][:primaryCaregiver][:icn]))

      expect_any_instance_of(MVI::Service).to receive(:find_profile_by_attributes).with(
        OpenStruct.new(
          {
            first_name: parsed_form['veteran']['fullName']['first'],
            middle_name: parsed_form['veteran']['fullName']['middle'],
            last_name: parsed_form['veteran']['fullName']['last'],
            birth_date: parsed_form['veteran']['dateOfBirth'],
            gender: parsed_form['veteran']['gender'],
            ssn: parsed_form['veteran']['ssnOrTin']
          }
        )
      ).and_return(mvi_lookup_1)

      expect_any_instance_of(MVI::Service).to receive(:find_profile_by_attributes).with(
        OpenStruct.new(
          {
            first_name: parsed_form['primaryCaregiver']['fullName']['first'],
            middle_name: parsed_form['primaryCaregiver']['fullName']['middle'],
            last_name: parsed_form['primaryCaregiver']['fullName']['last'],
            birth_date: parsed_form['primaryCaregiver']['dateOfBirth'],
            gender: parsed_form['primaryCaregiver']['gender'],
            ssn: parsed_form['primaryCaregiver']['ssnOrTin']
          }
        )
      ).and_return(mvi_lookup_2)

      expect(carma_submission).to receive(:metadata=).with(expected[:metadata]).and_return(carma_submission)

      expect(carma_submission).to receive(:submit!) {
        expect(carma_submission).to receive(:carma_case_id).and_return(expected[:carma_case_id])
        expect(carma_submission).to receive(:submitted_at).and_return(expected[:submitted_at])
      }

      submission = subject.submit_claim!(claim)

      expect(submission).to be_an_instance_of(Form1010cg::Submission)
      expect(submission.carma_case_id).to eq(expected[:carma_case_id])
      expect(submission.submitted_at).to eq(expected[:submitted_at])
    end

    describe 'MVI lookup' do
      RSpec.shared_examples 'non required mvi search' do
        it 'will not search mvi when person not provided' do
        end

        it 'will attach the icn found' do
        end

        it 'will not raise error when not found' do
        end
      end

      context 'for veteran' do
      end

      context 'for Primary Caregiver' do
      end

      context 'for Secondary Caregiver One' do
        it_behaves_like 'non required mvi search', 'secondaryCaregiverOne'
      end

      context 'for Secondary Caregiver Two' do
        it_behaves_like 'non required mvi search', 'secondaryCaregiverTwo'
      end
    end
  end
end
