# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'VirtualAgentClaims', type: :request do
  let(:user) { create(:user, :loa3) }
  let(:claim) { create(:evss_claim, user_uuid: user.uuid) }

  describe 'GET /v0/virtual_agent/claim' do

    let!(:claim) do
      FactoryBot.create(:evss_claim, id: 1, evss_id: 600_118_854,
                        user_uuid: user.uuid)
      FactoryBot.create(:evss_claim, id: 2, evss_id: 600_118_855,
                        user_uuid: user.uuid)
      FactoryBot.create(:evss_claim, id: 3, evss_id: 600_118_851,
                        user_uuid: user.uuid)
    end

    it 'returns information on multiple open compensation claims in descending chronological order by updated date' do
      sign_in_as(user)

      get '/v0/virtual_agent/claim'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
      expect(JSON.parse(response.body)['data']).to eq nil

      # run job
      VCR.use_cassette('evss/claims/claims_multiple_open_compensation_claims') do
        EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
      end
      VCR.use_cassette('evss/claims/claim_with_docs1') do
        EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, 1)
      end
      VCR.use_cassette('evss/claims/claim_with_docs2') do
        EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, 2)
      end
      VCR.use_cassette('evss/claims/claim_with_docs3') do
        EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, 3)
      end

      get '/v0/virtual_agent/claim'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
      expect(JSON.parse(response.body)['data']).to be_kind_of(Array)

      expect(JSON.parse(response.body)['data'].size).to equal(3)
      expect(JSON.parse(response.body)['data']).to eq([{
                                                        'claim_type' => 'Compensation',
                                                        'claim_status' => 'UNDER REVIEW',
                                                        'filing_date' => '02/08/2017',
                                                        'evss_id' => '600118854',
                                                        'updated_date' => '03/10/2018',
                                                        'va_representative' => 'JOHN SMITH'
                                                      },
                                                       {
                                                         'claim_type' => 'Compensation',
                                                         'claim_status' => 'UNDER REVIEW',
                                                         'filing_date' => '01/08/2018',
                                                         'evss_id' => '600118855',
                                                         'updated_date' => '01/10/2018',
                                                         'va_representative' => 'VAL KILMER'
                                                       },
                                                       {
                                                         'claim_type' => 'Compensation',
                                                         'claim_status' => 'UNDER REVIEW',
                                                         'filing_date' => '12/08/2017',
                                                         'evss_id' => '600118851',
                                                         'updated_date' => '12/08/2017',
                                                         'va_representative' => 'JESSE BROWN'
                                                       }])
    end

    describe 'for a single claim' do
      let!(:claim) do
        FactoryBot.create(:evss_claim, id: 3, evss_id: 600_118_851,
                          user_uuid: user.uuid)
      end

      it 'returns information on single open compensation claim' do
        sign_in_as(user)

        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
        expect(JSON.parse(response.body)['data']).to eq nil

        # run job
        VCR.use_cassette('evss/claims/claims_with_single_open_compensation_claim') do
          EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
        end
        VCR.use_cassette('evss/claims/claim_with_docs1') do
          EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, 3)
        end

        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
        expect(JSON.parse(response.body)['data']).to be_kind_of(Array)
        expect(JSON.parse(response.body)['data'].size).to equal(1)
        expect(JSON.parse(response.body)['data']).to include({
                                                               'claim_type' => 'Compensation',
                                                               'claim_status' => 'UNDER REVIEW',
                                                               'filing_date' => '12/08/2017',
                                                               'evss_id' => '600118851',
                                                               'updated_date' => '12/08/2017',
                                                               'va_representative' => 'JOHN SMITH'
                                                             })
      end

      it 'returns information on single open compensation claim with blank representative field when claim details service times out' do
        sign_in_as(user)

        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
        expect(JSON.parse(response.body)['data']).to eq nil

        # run job
        VCR.use_cassette('evss/claims/claims_with_single_open_compensation_claim') do
          EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
        end

        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
        expect(JSON.parse(response.body)['data']).to be_kind_of(Array)
        expect(JSON.parse(response.body)['data'].size).to equal(1)
        expect(JSON.parse(response.body)['data']).to include({
                                                                 'claim_type' => 'Compensation',
                                                                 'claim_status' => 'UNDER REVIEW',
                                                                 'filing_date' => '12/08/2017',
                                                                 'evss_id' => '600118851',
                                                                 'updated_date' => '12/08/2017',
                                                                 'va_representative' => '',
                                                             })
      end
    end

      describe 'test' do
        #let(:claims_service) { double('EVSSClaimServiceAsync') }
        #let(:current_user) { double(current_user) }
          fit 'returns information on single open compensation claim when claims details service requires polling' do
            sign_in_as(user)

            #allow(claims_service).to receive(:all) { [["hi"], 'REQUESTED'] }
            #allow(:current_user).to receive(:uuid) { 1 }
            allow(V0::VirtualAgent::VirtualAgentClaimController::service(user)).to receive(:all) { [["hi"], 'REQUESTED'] }

            #def service2
            #  foo.new(current_user)
            #end

            #controller.service -> service2 entity
            get '/v0/virtual_agent/claim'
            expect(response).to have_http_status(:ok)
            expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
            expect(JSON.parse(response.body)['data']).to eq nil
          end
      end



    it 'returns empty array when no open claims are found' do
      sign_in_as(user)
      get '/v0/virtual_agent/claim'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
      expect(JSON.parse(response.body)['data']).to eq nil

      # run job
      VCR.use_cassette('evss/claims/claims_trimmed_down') do
        EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
      end

      get '/v0/virtual_agent/claim'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
      expect(JSON.parse(response.body)['data']).to be_kind_of(Array)
      expect(JSON.parse(response.body)['data'].size).to equal(0)
    end

    it 'returns empty array when there are only closed compensation claims' do
      sign_in_as(user)
      get '/v0/virtual_agent/claim'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
      expect(JSON.parse(response.body)['data']).to eq nil

      # run job
      VCR.use_cassette('evss/claims/claims_historical_compensation') do
        EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
      end

      get '/v0/virtual_agent/claim'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
      expect(JSON.parse(response.body)['data']).to be_kind_of(Array)
      expect(JSON.parse(response.body)['data'].size).to equal(0)
    end

    describe 'for a user who has non-compensation and compensation claims' do
      let!(:claim) do
        FactoryBot.create(:evss_claim, id: 3, evss_id: 600_114_693,
                          user_uuid: user.uuid)
      end
      it 'returns information when there is a more recent non-compensation open claim' do
        sign_in_as(user)
        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
        expect(JSON.parse(response.body)['data']).to eq nil

        # run job
        VCR.use_cassette('evss/claims/claims_most_recent_dependent') do
          EVSS::RetrieveClaimsFromRemoteJob.new.perform(user.uuid)
        end
        VCR.use_cassette('evss/claims/claim_with_docs4') do
          EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, 3)
        end

        get '/v0/virtual_agent/claim'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
        expect(JSON.parse(response.body)['data']).to include({
                                                                 'claim_type' => 'Compensation',
                                                                 'claim_status' => 'CLAIM RECEIVED',
                                                                 'filing_date' => '09/28/2017',
                                                                 'evss_id' => '600114693',
                                                                 'updated_date' => '09/28/2017',
                                                                 'va_representative' => 'JESSE BROWN'
                                                             })
      end
    end


  end

  describe 'GET /v0/virtual_agent/claim/{EVSS_ID}' do
    let!(:claim) do
      FactoryBot.create(:evss_claim, id: 1, evss_id: 600_117_255,
                                     user_uuid: user.uuid)
    end

    it 'returns claims details of a specific claim' do
      sign_in_as(user)
      get '/v0/virtual_agent/claim/600117255'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'REQUESTED'
      expect(JSON.parse(response.body)['data']).to eq({ 'va_representative' => 'AMERICAN LEGION' })
      VCR.use_cassette('evss/claims/claim_with_docs') do
        EVSS::UpdateClaimFromRemoteJob.new.perform(user.uuid, claim.id)
      end
      get '/v0/virtual_agent/claim/600117255'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['meta']['sync_status']).to eq 'SUCCESS'
      expect(JSON.parse(response.body)['data']).to eq({ 'va_representative' => 'VENKATA KOMMOJU' })
    end
  end
end
