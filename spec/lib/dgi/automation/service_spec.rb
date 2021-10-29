# frozen_string_literal: true

require 'rails_helper'
require 'dgi/automation/service'

Rspec.describe DGI::Automation::Service do
  let(:user) { FactoryBot.create(:evss_user, :loa3) }
  let(:service) { DGI::Automation::Service.new(user) }

  describe '#post_claimant_info' do
    let(:faraday_response) { double('faraday_connection') }

    before do
      allow(faraday_response).to receive(:env)
    end

    context 'with a successful submission' do
      it 'successfully receives an military Claimant object' do
        VCR.use_cassette('dgi/automation/post_claimant_info') do
          response = service.post_claimant_info({'ssn': '539139735'})

          expect(response.status).to eq(201)
          expect(response.body['military_claimant']['claimant']['claimant_id']).to eq(1000000000000261)
        end
      end
    end
  end
end
