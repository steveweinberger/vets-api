# frozen_string_literal: true

require 'rails_helper'

module AppealsApi
  RSpec.describe ContestableIssuesRetrieval do
    describe '#start!' do
      it 'makes a request to caseflow' do
        headers = { 'X-VA-Receipt-Date' => '1900-01-01', 'X-VA-SSN' => '123456789' }
        caseflow_service_double = instance_double('Caseflow::Service')
        allow(Caseflow::Service).to receive(:new).and_return(caseflow_service_double)
        allow(caseflow_service_double).to receive(:get_contestable_issues)

        ContestableIssuesRetrieval.new(decision_review_type: 'notice_of_disagreements', raw_headers: headers).start!

        expect(caseflow_service_double).to have_received(:get_contestable_issues)
      end

      it 'filters the response for NODs' do

      end

      it 'returns an error if a header is missing' do
        request_headers = { 'X-VA-Receipt-Date' => '1900-01-01' }
        retrieval = ContestableIssuesRetrieval.new(decision_review_type: 'nonsense', raw_headers: request_headers).start!

        expect(retrieval[:errors].first).to eq(
          {
            title: "Missing required fields",
            detail: "One or more expected fields were not found",
            code: "145",
            source: {pointer: "/"},
            links: [],
            status: "422",
            meta: { missing_fields: ["X-VA-SSN"] }
          }
        )
      end

      it 'returns a 502 if Caseflow doesnt return usable JSON' do
        headers = { 'X-VA-Receipt-Date' => '1900-01-01', 'X-VA-SSN' => '123456789' }
        caseflow_service_double = instance_double('Caseflow::Service')
        allow(Caseflow::Service).to receive(:new).and_return(caseflow_service_double)
        allow(caseflow_service_double).to receive(:get_contestable_issues).and_raise(Common::Exceptions::BackendServiceException, 'Caseflow doesnt know how to deal with your request')

        response = ContestableIssuesRetrieval.new(decision_review_type: 'notice_of_disagreements', raw_headers: headers).start!

        expect(response[:errors].first[:detail]).to eq('Received an unusable response from Caseflow.')
        expect(response[:status]).to eq(502)
      end

      it 'returns caseflow error status if Caseflow returns a 4xx' do
        VCR.use_cassette('caseflow/higher_level_reviews/bad_date') do
          headers = { 'X-VA-Receipt-Date' => '1900-01-01', 'X-VA-SSN' => '123456789' }
          response = ContestableIssuesRetrieval.new(decision_review_type: 'higher_level_reviews', benefit_type: 'compensation', raw_headers: headers).start!
          binding.pry
          expect(response[:errors].first[:detail]).to eq('One or more unprocessable properties or validation errors')
          expect(response[:status]).to eq(422)
        end
      end

      it 'returns an error if an invalid decision_review_type has been passed in' do
        headers = { 'X-VA-Receipt-Date' => '1900-01-01', 'X-VA-SSN' => '123456789' }
        retrieval = ContestableIssuesRetrieval.new(decision_review_type: 'nonsense', raw_headers: headers).start!

        expect(retrieval).to eq(
          errors: [
            {
              title: 'Unprocessable Entity',
              code: 'unprocessable_entity',
              detail: "decision_review_type must be one of: #{ContestableIssuesRetrieval::VALID_DECISION_REVIEW_TYPES.join(', ')}",
              status: '422'
            }
          ],
          status: '422'
        )
      end
    end
  end
end
