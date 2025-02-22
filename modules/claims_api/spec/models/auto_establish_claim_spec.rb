# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimsApi::AutoEstablishedClaim, type: :model do
  let(:auto_form) { build(:auto_established_claim, auth_headers: { some: 'data' }) }
  let(:pending_record) { create(:auto_established_claim) }

  describe 'encrypted attributes' do
    it 'does the thing' do
      expect(subject).to encrypt_attr(:form_data)
      expect(subject).to encrypt_attr(:auth_headers)
      expect(subject).to encrypt_attr(:file_data)
    end
  end

  it 'writes flashes and special issues to log on create' do
    expect(Rails.logger).to receive(:info)
      .with(/ClaimsApi: Claim\[.+\] contains the following flashes - \["Hardship", "Homeless"\]/)
    expect(Rails.logger).to receive(:info)
      .with(%r{ClaimsApi: Claim\[.+\] contains the following special issues - \[.*FDC.*PTSD/2.*\]})
    pending_record
  end

  describe 'validate_service_dates' do
    context 'when activeDutyEndDate is before activeDutyBeginDate' do
      it 'throws an error' do
        auto_form.form_data = { 'serviceInformation' => { 'servicePeriods' => [{
          'activeDutyBeginDate' => '1991-05-02',
          'activeDutyEndDate' => '1990-04-05'
        }] } }

        expect(auto_form.save).to eq(false)
        expect(auto_form.errors.messages).to include(:activeDutyBeginDate)
      end
    end

    context 'when activeDutyEndDate is not provided' do
      it 'throws an error' do
        auto_form.form_data = { 'serviceInformation' => { 'servicePeriods' => [{
          'activeDutyBeginDate' => '1991-05-02',
          'activeDutyEndDate' => nil
        }] } }

        expect(auto_form.save).to eq(true)
      end
    end

    context 'when activeDutyBeginDate is not provided' do
      it 'throws an error' do
        auto_form.form_data = { 'serviceInformation' => { 'servicePeriods' => [{
          'activeDutyBeginDate' => nil,
          'activeDutyEndDate' => '1990-04-05'
        }] } }

        expect(auto_form.save).to eq(false)
        expect(auto_form.errors.messages).to include(:activeDutyBeginDate)
      end
    end
  end

  describe 'pending?' do
    context 'no pending records' do
      it 'is false' do
        expect(described_class.pending?('123')).to be(false)
      end
    end

    context 'with pending records' do
      it 'truthies and return the record' do
        result = described_class.pending?(pending_record.id)
        expect(result).to be_truthy
        expect(result.id).to eq(pending_record.id)
      end
    end
  end

  describe 'translate form_data' do
    it 'checks an active claim date' do
      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['claimDate']).to eq('1990-01-03')
    end

    it 'adds an active claim date' do
      pending_record.form_data.delete('claimDate')
      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['claimDate']).to eq(pending_record.created_at.to_date.to_s)
    end

    it 'adds an identifier for Lighthouse submissions' do
      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['claimSubmissionSource']).to eq('Lighthouse')
    end

    it 'converts special issues to EVSS codes' do
      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['disabilities'].first['specialIssues']).to eq(['PTSD_2'])
    end

    it 'converts homelessness situation type to EVSS code' do
      payload = JSON.parse(pending_record.to_internal)
      actual = payload['form526']['veteran']['homelessness']['currentlyHomeless']['homelessSituationType']
      expect(actual).to eq('FLEEING_CURRENT_RESIDENCE')
    end

    describe 'when days until release is between 90 and 180 days' do
      it 'sets bddQualified to true' do
        temp_form_data = pending_record.form_data
        temp_form_data['serviceInformation'] = {
          'servicePeriods' => [
            {
              'serviceBranch' => 'Air Force',
              'activeDutyBeginDate' => '1991-05-02',
              'activeDutyEndDate' => (Time.zone.now.to_date + 100.days).to_s
            }
          ]
        }
        pending_record.form_data = temp_form_data

        payload = JSON.parse(pending_record.to_internal)
        expect(payload['form526']['bddQualified']).to eq(true)
      end
    end

    describe 'when days until release is less than 90 days' do
      it 'sets bddQualified to false' do
        temp_form_data = pending_record.form_data
        temp_form_data['serviceInformation'] = {
          'servicePeriods' => [
            {
              'serviceBranch' => 'Air Force',
              'activeDutyBeginDate' => '1991-05-02',
              'activeDutyEndDate' => (Time.zone.now.to_date + 80.days).to_s
            }
          ]
        }
        pending_record.form_data = temp_form_data

        payload = JSON.parse(pending_record.to_internal)
        expect(payload['form526']['bddQualified']).to eq(false)
      end
    end

    describe 'when days until release is greater than 180 days' do
      describe 'when Veteran has previous service period' do
        it 'sets bddQualified to false' do
          temp_form_data = pending_record.form_data
          temp_form_data['serviceInformation'] = {
            'servicePeriods' => [
              {
                'serviceBranch' => 'Air Force',
                'activeDutyBeginDate' => '1991-05-02',
                'activeDutyEndDate' => (Time.zone.now.to_date + 190.days).to_s
              },
              {
                'serviceBranch' => 'Army',
                'activeDutyBeginDate' => '1991-05-02',
                'activeDutyEndDate' => (Time.zone.now.to_date - 1.day).to_s
              }
            ]
          }
          pending_record.form_data = temp_form_data

          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['bddQualified']).to eq(false)
        end
      end

      describe 'when Veteran does not have previous service period' do
        it 'raises an exception' do
          temp_form_data = pending_record.form_data
          temp_form_data['serviceInformation'] = {
            'servicePeriods' => [
              {
                'serviceBranch' => 'Air Force',
                'activeDutyBeginDate' => '1991-05-02',
                'activeDutyEndDate' => (Time.zone.now.to_date + 190.days).to_s
              }
            ]
          }
          pending_record.form_data = temp_form_data

          expect { pending_record.to_internal }.to raise_error(::Common::Exceptions::UnprocessableEntity)
        end
      end
    end

    describe "breaking out 'separationPay.receivedDate'" do
      it 'breaks it out by year, month, day' do
        temp_form_data = pending_record.form_data
        temp_form_data.merge!(
          {
            'servicePay' => {
              'separationPay' => {
                'received' => true,
                'receivedDate' => '2018-03-02',
                'payment' => {
                  'serviceBranch' => 'Air Force',
                  'amount' => 100
                }
              }
            }
          }
        )
        pending_record.form_data = temp_form_data

        payload = JSON.parse(pending_record.to_internal)
        expect(payload['form526']['servicePay']['separationPay']['receivedDate']).to include(
          'year' => '2018',
          'month' => '3',
          'day' => '2'
        )
      end
    end

    describe "breaking out 'disabilities.approximateBeginDate'" do
      it 'breaks it out by year, month, day' do
        disability = pending_record.form_data['disabilities'].first
        disability.merge!(
          {
            'approximateBeginDate' => '1989-12-01'
          }
        )
        pending_record.form_data['disabilities'][0] = disability

        payload = JSON.parse(pending_record.to_internal)
        expect(payload['form526']['disabilities'].first['approximateBeginDate']).to include(
          'year' => '1989',
          'month' => '12',
          'day' => '1'
        )
      end
    end

    describe "handling 'changeOfAddress.endingDate'" do
      context "when 'changeOfAddress' is provided" do
        let(:change_of_address) do
          {
            'beginningDate' => (Time.zone.now + 1.month).to_date.to_s,
            'endingDate' => ending_date,
            'addressChangeType' => address_change_type,
            'addressLine1' => '1234 Couch Street',
            'city' => 'New York City',
            'state' => 'NY',
            'type' => 'DOMESTIC',
            'zipFirstFive' => '12345',
            'country' => 'USA'
          }
        end
        let(:ending_date) { (Time.zone.now + 6.months).to_date.to_s }

        context "when 'changeOfAddress.addressChangeType' is 'TEMPORARY'" do
          let(:address_change_type) { 'TEMPORARY' }

          context "and 'changeOfAddress.endingDate' is not provided" do
            it "sets 'changeOfAddress.endingDate' to 1 year in the future" do
              change_of_address.delete('endingDate')
              pending_record.form_data['veteran']['changeOfAddress'] = change_of_address

              payload = JSON.parse(pending_record.to_internal)
              transformed_ending_date = payload['form526']['veteran']['changeOfAddress']['endingDate']

              expect(transformed_ending_date).to eq((Time.zone.now.to_date + 1.year).to_s)
            end
          end

          context "and 'changeOfAddress.endingDate' is provided" do
            it "does not change 'changeOfAddress.endingDate'" do
              pending_record.form_data['veteran']['changeOfAddress'] = change_of_address

              payload = JSON.parse(pending_record.to_internal)
              untouched_ending_date = payload['form526']['veteran']['changeOfAddress']['endingDate']

              expect(untouched_ending_date).to eq(ending_date)
            end
          end
        end

        context "when 'changeOfAddress.addressChangeType' is 'PERMANENT'" do
          let(:address_change_type) { 'PERMANENT' }

          context "and 'changeOfAddress.endingDate' is provided" do
            let(:ending_date) { (Time.zone.now + 6.months).to_date.to_s }

            it "removes the 'changeOfAddress.endingDate'" do
              pending_record.form_data['veteran']['changeOfAddress'] = change_of_address

              payload = JSON.parse(pending_record.to_internal)
              transformed_ending_date = payload['form526']['veteran']['changeOfAddress']['endingDate']

              expect(transformed_ending_date).to eq(nil)
            end
          end

          context "and 'changeOfAddress.endingDate' is not provided" do
            it "does not add a 'changeOfAddress.endingDate'" do
              change_of_address.delete('endingDate')
              pending_record.form_data['veteran']['changeOfAddress'] = change_of_address

              payload = JSON.parse(pending_record.to_internal)
              untouched_ending_date = payload['form526']['veteran']['changeOfAddress']['endingDate']

              expect(untouched_ending_date).to eq(nil)
            end
          end
        end
      end
    end

    describe "handling an old 'serviceBranch' value" do
      context "when 'serviceBranch' is 'Air Force Academy'" do
        let(:old_value) { 'Air Force Academy' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Air Force')
        end
      end

      context "when 'serviceBranch' is 'Air Force Reserves'" do
        let(:old_value) { 'Air Force Reserves' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Air Force')
        end
      end

      context "when 'serviceBranch' is 'Army Reserves'" do
        let(:old_value) { 'Army Reserves' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Army')
        end
      end

      context "when 'serviceBranch' is 'Army Air Corps or Army Air Force'" do
        let(:old_value) { 'Army Air Corps or Army Air Force' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Army')
        end
      end

      context "when 'serviceBranch' is 'Army Nurse Corps'" do
        let(:old_value) { 'Army Nurse Corps' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Army')
        end
      end

      context "when 'serviceBranch' is 'Women's Army Corps'" do
        let(:old_value) { "Women's Army Corps" }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Army')
        end
      end

      context "when 'serviceBranch' is 'US Military Academy'" do
        let(:old_value) { 'US Military Academy' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Army')
        end
      end

      context "when 'serviceBranch' is 'Coast Guard Reserves'" do
        let(:old_value) { 'Coast Guard Reserves' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Coast Guard')
        end
      end

      context "when 'serviceBranch' is 'Coast Guard Academy'" do
        let(:old_value) { 'Coast Guard Academy' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Coast Guard')
        end
      end

      context "when 'serviceBranch' is 'Marine Corps'" do
        let(:old_value) { 'Marine Corps' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Marine')
        end
      end

      context "when 'serviceBranch' is 'Marine Corps Reserves'" do
        let(:old_value) { 'Marine Corps Reserves' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Marine')
        end
      end

      context "when 'serviceBranch' is 'Merchant Marine'" do
        let(:old_value) { 'Merchant Marine' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Marine')
        end
      end

      context "when 'serviceBranch' is 'Navy Reserves'" do
        let(:old_value) { 'Navy Reserves' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Navy')
        end
      end

      context "when 'serviceBranch' is 'Naval Academy'" do
        let(:old_value) { 'Naval Academy' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Navy')
        end
      end

      context "when 'serviceBranch' is 'Other'" do
        let(:old_value) { 'Other' }

        it 'maps to a value accepted by EVSS' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq('Unknown')
        end
      end

      context "when 'serviceBranch' is unmapped" do
        let(:old_value) { 'Some Random Value' }

        it 'remains unchanged' do
          pending_record.form_data['serviceInformation']['servicePeriods'].first['serviceBranch'] = old_value
          payload = JSON.parse(pending_record.to_internal)
          expect(payload['form526']['serviceInformation']['servicePeriods'].first['serviceBranch']).to eq(old_value)
        end
      end

      describe "scrubbing 'specialIssues' on 'secondaryDisabilities'" do
        context "when a 'secondaryDisability' has 'specialIssues'" do
          it "removes the 'specialIssues' attribute" do
            pending_record.form_data['disabilities'].first['secondaryDisabilities'].first['specialIssues'] = []
            pending_record.form_data['disabilities'].first['secondaryDisabilities'].first['specialIssues'] << 'ALS'

            payload = JSON.parse(pending_record.to_internal)
            special_issues = payload['form526']['disabilities'].first['secondaryDisabilities'].first['specialIssues']

            expect(special_issues).to be_nil
          end
        end

        context "when a 'secondaryDisability' does not have 'specialIssues'" do
          it 'does not change anything' do
            pre_processed_disabilities = pending_record.form_data['disabilities']
            payload = JSON.parse(pending_record.to_internal)
            post_processed_disabilities = payload['form526']['disabilities']

            expect(pre_processed_disabilities).eql?(post_processed_disabilities)
          end
        end

        context "when a 'secondaryDisability' does not exist" do
          it 'does not change anything' do
            pending_record.form_data['disabilities'].first.delete('secondaryDisabilities')

            pre_processed_disabilities = pending_record.form_data['disabilities']
            payload = JSON.parse(pending_record.to_internal)
            post_processed_disabilities = payload['form526']['disabilities']

            expect(pre_processed_disabilities).eql?(post_processed_disabilities)
          end
        end
      end
    end
  end

  describe 'evss_id_by_token' do
    context 'with a record' do
      let(:evss_record) { create(:auto_established_claim, evss_id: 123_456) }

      it 'returns the evss id of that record' do
        expect(described_class.evss_id_by_token(evss_record.token)).to eq(123_456)
      end
    end

    context 'with no record' do
      it 'returns nil' do
        expect(described_class.evss_id_by_token('thisisntatoken')).to be(nil)
      end
    end

    context 'with record without evss id' do
      it 'returns nil' do
        expect(described_class.evss_id_by_token(pending_record.token)).to be(nil)
      end
    end
  end

  context 'finding by ID or EVSS ID' do
    let(:evss_record) { create(:auto_established_claim, evss_id: 123_456) }

    before do
      evss_record
    end

    it 'finds by model id' do
      expect(described_class.get_by_id_or_evss_id(evss_record.id).id).to eq(evss_record.id)
    end

    it 'finds by evss id' do
      expect(described_class.get_by_id_or_evss_id(123_456).id).to eq(evss_record.id)
    end
  end

  describe '#set_file_data!' do
    it 'stores the file_data and give me a full evss document' do
      file = Rack::Test::UploadedFile.new(
        "#{::Rails.root}/modules/claims_api/spec/fixtures/extras.pdf"
      )

      auto_form.set_file_data!(file, 'docType')
      auto_form.save!
      auto_form.reload

      expect(auto_form.file_data).to have_key('filename')
      expect(auto_form.file_data).to have_key('doc_type')

      expect(auto_form.file_name).to eq(auto_form.file_data['filename'])
      expect(auto_form.document_type).to eq(auto_form.file_data['doc_type'])
    end
  end

  describe "breaking out 'treatments.startDate'" do
    it 'breaks it out by year, month, day' do
      treatments = [
        {
          'center' => {
            'name' => 'Some Treatment Center',
            'country' => 'United States of America'
          },
          'treatedDisabilityNames' => [
            'PTSD (post traumatic stress disorder)'
          ],
          'startDate' => '1985-01-01'
        }
      ]

      pending_record.form_data['treatments'] = treatments

      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['treatments'].first['startDate']).to include(
        'year' => '1985',
        'month' => '1',
        'day' => '1'
      )
    end
  end

  describe "breaking out 'treatments.endDate'" do
    it 'breaks it out by year, month, day' do
      treatments = [
        {
          'center' => {
            'name' => 'Some Treatment Center',
            'country' => 'United States of America'
          },
          'treatedDisabilityNames' => [
            'PTSD (post traumatic stress disorder)'
          ],
          'startDate' => '1985-01-01',
          'endDate' => '1986-01-01'
        }
      ]

      pending_record.form_data['treatments'] = treatments

      payload = JSON.parse(pending_record.to_internal)
      expect(payload['form526']['treatments'].first['endDate']).to include(
        'year' => '1986',
        'month' => '1',
        'day' => '1'
      )
    end
  end

  describe "assigning 'applicationExpirationDate'" do
    context "when 'applicationExpirationDate' is not provided" do
      it 'assigns a value 1 year from today' do
        pending_record.form_data.delete('applicationExpirationDate')

        payload = JSON.parse(pending_record.to_internal)
        application_expiration_date = Date.parse(payload['form526']['applicationExpirationDate'])
        expect(application_expiration_date).to eq(Time.zone.now.to_date + 1.year)
      end
    end

    context "when 'applicationExpirationDate' is provided" do
      it 'leaves the original provided value' do
        original_value = Date.parse(pending_record.form_data['applicationExpirationDate'])
        payload = JSON.parse(pending_record.to_internal)
        application_expiration_date = Date.parse(payload['form526']['applicationExpirationDate'])
        expect(original_value).to eq(application_expiration_date)
      end
    end
  end

  describe 'massaging invalid disability names' do
    describe "handling the length of a 'disability.name'" do
      context "when a 'disability.name' is longer than 255 characters" do
        it 'truncates it' do
          invalid_length_name = 'X' * 300
          pending_record.form_data['disabilities'].first['name'] = invalid_length_name

          payload = JSON.parse(pending_record.to_internal)
          disability_name = payload['form526']['disabilities'].first['name']

          expect(disability_name.length).to eq(255)
        end
      end

      context "when a 'disability.name' is shorter than 255 characters" do
        it 'does not change it' do
          valid_length_name = 'X' * 20
          pending_record.form_data['disabilities'].first['name'] = valid_length_name

          payload = JSON.parse(pending_record.to_internal)
          disability_name = payload['form526']['disabilities'].first['name']

          expect(valid_length_name).to eq(disability_name)
        end
      end

      context "when a 'disability.name' is exactly 255 characters" do
        it 'does not change it' do
          valid_length_name = 'X' * 255
          pending_record.form_data['disabilities'].first['name'] = valid_length_name

          payload = JSON.parse(pending_record.to_internal)
          disability_name = payload['form526']['disabilities'].first['name']

          expect(valid_length_name).to eq(disability_name)
        end
      end
    end

    describe "handling invalid characters in a 'disability.name'" do
      context "when a 'disability.name' has invalid characters" do
        it 'the invalid characters are removed' do
          name_with_invalid_characters = 'abc `~!@#$%^&*=+123'
          pending_record.form_data['disabilities'].first['name'] = name_with_invalid_characters

          payload = JSON.parse(pending_record.to_internal)
          disability_name = payload['form526']['disabilities'].first['name']

          expect(disability_name.include?('abc 123')).to eq(true)
          expect(disability_name.include?('`')).to eq(false)
          expect(disability_name.include?('~')).to eq(false)
          expect(disability_name.include?('!')).to eq(false)
          expect(disability_name.include?('@')).to eq(false)
          expect(disability_name.include?('#')).to eq(false)
          expect(disability_name.include?('$')).to eq(false)
          expect(disability_name.include?('%')).to eq(false)
          expect(disability_name.include?('^')).to eq(false)
          expect(disability_name.include?('&')).to eq(false)
          expect(disability_name.include?('*')).to eq(false)
          expect(disability_name.include?('=')).to eq(false)
          expect(disability_name.include?('+')).to eq(false)
        end
      end

      context "when a 'disability.name' only has valid characters" do
        it 'nothing is changed' do
          name_with_only_valid_characters = "abc \-'.,/()123"
          pending_record.form_data['disabilities'].first['name'] = name_with_only_valid_characters

          payload = JSON.parse(pending_record.to_internal)
          disability_name = payload['form526']['disabilities'].first['name']

          expect(name_with_only_valid_characters).to eq(disability_name)
        end
      end
    end
  end
end
