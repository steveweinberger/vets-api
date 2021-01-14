# frozen_string_literal: true

require 'rails_helper'

# outputs debug string into specs
# "D, [2021-01-14T20:26:08.449720 #29] DEBUG -- : HTTPI /peer GET request to internal-dsva-vagov-dev-fwdproxy-1893365470.us-gov-west-1.elb.amazonaws.com (net_http)\n"

RSpec.describe BGS::PeopleService do
  let(:user) { FactoryBot.create(:evss_user, :loa3) }

  describe '#find_person_by_participant_id' do
    it 'returns a person hash given a participant_id' do
      VCR.use_cassette('bgs/people_service/person_data') do
        service = BGS::PeopleService.new(user)
        response = service.find_person_by_participant_id

        expect(response).to include(:file_nbr, :brthdy_dt, :last_nm)
      end
    end

    context 'no user found' do
      it 'returns an empty hash' do
        VCR.use_cassette('bgs/people_service/no_person_data') do
          allow(user).to receive(:participant_id).and_return('11111111111')

          service = BGS::PeopleService.new(user)
          response = service.find_person_by_participant_id

          expect(response).to be_empty
        end
      end

      it 'creates a PersonalInformationLog' do
        VCR.use_cassette('bgs/people_service/no_person_data') do
          allow(user).to receive(:participant_id).and_return('11111111111')
          expect(PersonalInformationLog).to receive(:create)

          service = BGS::PeopleService.new(user)
          service.find_person_by_participant_id
        end
      end
    end
  end
end
