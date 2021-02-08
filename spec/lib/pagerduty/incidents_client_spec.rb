require 'rails_helper'
require 'pagerduty/incidents_client'

describe PagerDuty::IncidentsClient, type: :request do

  let(:incidents_client) { described_class.new }
  let(:response) {}
  context 'making incidents api request' do

    describe 'GET incidents' do 
      let(:params) {{}}
      it 'will return 200' do
        VCR.use_cassette('pagerduty/get_incidents_200', match_requests_on: %i[method uri]) do
          response = incidents_client.get_incidents(params)
          expect(response['incidents']).to be_an_instance_of(Array)
        end
      end
    end
  end
end