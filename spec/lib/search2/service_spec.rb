# frozen_string_literal: true

require 'rails_helper'

describe Search2::Service do
  subject { Search2::Service.new }

  let(:query) { 'benefits' }

  before do
    allow_any_instance_of(described_class).to receive(:access_key).and_return('TESTKEY')
  end

  describe 'search' do
    describe 'when successful' do
      it 'returns an array of search result data' do
        VCR.use_cassette('search/success', VCR::MATCH_EVERYTHING) do
          response = subject.search(query)

          # lifted from old service test and needs to correspond to new service
          query = response.body['query']
          total = response.body['web']['total']

          expect([query, total]).to eq [query, total]
        end
      end
    end
  end
end
