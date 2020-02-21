# frozen_string_literal: true

require 'rails_helper'
require 'support/error_details'

RSpec.describe "ExternalApi::Search::SearchesController", type: :request do
  include SchemaMatchers
  include ErrorDetails

  describe 'GET /services/search/search' do
    context 'with a 200 response' do
      fit 'matches the search schema', :aggregate_failures do
        VCR.use_cassette('search/success') do
          get '/services/search/search', params: { query: 'benefits' }
          results = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(response).to match_response_schema('search')
        end
      end

      it 'returns an array of hash search results in its body', :aggregate_failures do
        VCR.use_cassette('search/success') do
          get '/services/search/search', params: { query: 'benefits' }

          body    = JSON.parse response.body
          results = body.dig('data', 'attributes', 'body', 'web', 'results')
          result  = results.first

          expect(results.class).to eq Array
          expect(result.class).to eq Hash
          expect(result.keys).to contain_exactly 'title', 'url', 'snippet', 'publication_date'
        end
      end
    end

    context 'with an empty query string' do
      it 'matches the errors schema', :aggregate_failures do
        VCR.use_cassette('search/empty_query') do
          get '/services/search/search', params: { query: '' }

          expect(response).to have_http_status(:bad_request)
          expect(response).to match_response_schema('errors')
        end
      end
    end

    context 'with un-sanitized parameters' do
      it 'sanitizes the input, stripping all tags and attributes that are not whitelisted' do
        VCR.use_cassette('search/success') do
          dirty_params     = '<script>alert(document.cookie);</script>'
          sanitized_params = 'alert(document.cookie);'

          expect(Search2::Service).to receive(:new).with(sanitized_params, '2')

          get '/services/search/search', params: { query: dirty_params, page: 2 }
        end
      end
    end

    context 'with pagination' do
      let(:query_term) { 'benefits' }

      context 'when the endpoint is being called' do
        context 'with a page' do
          it 'passes the page request to the search service object' do
            expect(Search2::Service).to receive(:new).with(query_term, '2')

            get '/services/search/search', params: { query: query_term, page: 2 }
          end
        end

        context 'with no page present' do
          it 'passes page=nil to the search service object' do
            expect(Search2::Service).to receive(:new).with(query_term, nil)

            get '/services/search/search', params: { query: query_term }
          end
        end
      end
    end
  end

end
