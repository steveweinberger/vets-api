# frozen_string_literal: true

require 'rails_helper'
require 'lgy/service'

describe LGY::Service do
  let(:user) { FactoryBot.create(:evss_user, :loa3) }

  describe '#get_determination' do
    subject { described_class.new(edipi: user.edipi, icn: user.icn).get_determination }

    context 'when response is eligible' do
      before { VCR.insert_cassette 'lgy/determination_eligible' }

      after { VCR.eject_cassette 'lgy/determination_eligible' }

      it 'response code is a 200' do
        expect(subject.status).to eq 200
      end

      it "response body['status'] is ELIGIBLE" do
        expect(subject.body['status']).to eq 'ELIGIBLE'
      end

      it "response body['determination_date'] exists" do
        expect(subject.body).to include 'determination_date'
      end
    end
  end

  #   context 'with an automatically approved coe' do
  #     it 'does not find an application' do
  #       VCR.use_cassette('lgy/application_not_found') do
  #         response = service.get_application

  #         expect(response.status).to eq(404)
  #         expect(response.body['status']).to eq(404)
  #         expect(response.body.key?('lgy_request_uuid')).to eq(true)
  #         expect(response.body['errors'][0]['message']).to eq('Not Found')
  #       end
  #     end
  #   end
  # end
end
