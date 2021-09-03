# frozen_string_literal: true

class AppealsApi::V2::ContestableIssuesControllerSwagger
  include Swagger::Blocks

  read_file = ->(path) { File.read(AppealsApi::Engine.root.join(*path)) }
  read_json = ->(path) { JSON.parse(read_file.call(path)) }
  read_json_from_same_dir = ->(filename) { read_json.call(['app', 'swagger', 'appeals_api', 'v2', filename]) }

  swagger_path '/contestable_issues/:decision_review_type' do
    operation :get, tags: ['Contestable Issues'] do
      key :operationId, 'getContestableIssues'

      key :summary, 'Returns all contestable issues for a specific veteran.'

      description = 'Returns all issues associated with a Veteran that have' \
        'not previously been decided by a Notice of Disagreement' \
        'as of the `receiptDate`. Not all issues returned are guaranteed to be eligible for appeal.' \
        'Associate these results when creating a new Notice of Disagreement.'
      key :description, description

      parameter name: 'decision_review_type', in: 'query' do
        key :required, true
        key :description, 'required to determine the decision review for requested contestable issues'
        key :enum, %w[higher_level_reviews notice_of_disagreements supplemental_claims]
      end

      parameter name: 'X-VA-SSN', in: 'header', description: 'veteran\'s ssn' do
        key :description, 'Either X-VA-SSN or X-VA-File-Number is required'
        schema '$ref': 'X-VA-SSN'
      end

      parameter name: 'X-VA-File-Number', in: 'header', description: 'veteran\'s file number' do
        key :description, 'Either X-VA-SSN or X-VA-File-Number is required'
        schema type: :string
      end

      parameter name: 'X-VA-Receipt-Date', in: 'header', required: true do
        desc = '(yyyy-mm-dd) In order to determine contestability of issues, ' \
          'the receipt date of a hypothetical Decision Review must be specified.'
        key :description, desc

        schema type: :string, format: :date
      end

      parameter name: 'benefit_type', in: 'body' do
        key :required, true
        key :description, 'required for Higher Level Reviews'
        key :type, :string
        key :example, 'compensation'
      end

      key :responses, read_json_from_same_dir['responses_contestable_issues.json']
      security do
        key :apikey, []
      end
    end
  end
end
