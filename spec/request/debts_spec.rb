# frozen_string_literal: true

require 'rails_helper'

# outputs debug line during specs
# "D, [2021-01-14T20:16:23.232090 #29] DEBUG -- : HTTPI /peer GET request to internal-dsva-vagov-dev-fwdproxy-1893365470.us-gov-west-1.elb.amazonaws.com (net_http)\n"

RSpec.describe 'Debts API Endpoint', type: :request do
  include SchemaMatchers

  let(:user_details) do
    {
      first_name: 'Greg',
      last_name: 'Anderson',
      middle_name: 'A',
      birth_date: '1991-04-05',
      ssn: '796043735'
    }
  end

  let(:user) { build(:user, :loa3, user_details) }

  before do
    sign_in_as(user)
  end

  describe 'GET /v0/debts' do
    context 'with a veteran who has debts' do
      it 'returns a 200 with the array of debts' do
        VCR.use_cassette('bgs/people_service/person_data') do
          VCR.use_cassette('debts/get_letters', VCR::MATCH_EVERYTHING) do
            get '/v0/debts'
            expect(response).to have_http_status(:ok)
            expect(response).to match_response_schema('debts')
          end
        end
      end
    end
  end

  context 'with a veteran with empty ssn' do
    it 'returns an error' do
      VCR.use_cassette('debts/get_letters_empty_ssn', VCR::MATCH_EVERYTHING) do
        get '/v0/debts'
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
