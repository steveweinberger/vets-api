# frozen_string_literal: true

class AppealsApi::V2::HigherLevelReviewsControllerSwagger
  include Swagger::Blocks

  OBJ = :object
  HLR_TAG = ['Higher-Level Reviews'].freeze

  read_file = ->(path) { File.read(AppealsApi::Engine.root.join(*path)) }
  read_json = ->(path) { JSON.parse(read_file.call(path)) }
  read_json_from_same_dir = ->(filename) { read_json.call(['app', 'swagger', 'appeals_api', 'v2', filename]) }
  read_json_from_v1_dir = ->(filename) { read_json.call(['app', 'swagger', 'appeals_api', 'v1', filename]) }

  response_hlr_show_not_found = read_json_from_same_dir['response_hlr_show_not_found.json']
  response_hlr_create_error = read_json_from_same_dir['response_hlr_create_error.json']

  example_all_fields_used = read_json[['spec', 'fixtures', 'valid_200996_v2.json']]

  hlr_show_properties = {
    status: { type: 'string', enum: AppealsApi::HlrStatus::V2_STATUSES },
    updatedAt: { '$ref': '#/components/schemas/timeStamp' },
    createdAt: { '$ref': '#/components/schemas/timeStamp' },
    formData: { '$ref': '#/components/schemas/hlrCreate' }
  }
  hlr_show_type = :higherLevelReview
  hlr_show_schema = {
    type: OBJ,
    properties: {
      id: { '$ref': '#/components/schemas/uuid' },
      type: { type: :string, enum: [hlr_show_type] },
      attributes: { type: OBJ, properties: hlr_show_properties }
    }
  }

  response_hlr_show_success = lambda do
    time = '2020-04-23T21:06:12.531Z'
    attrs = { status: :processing, updatedAt: time, createdAt: time, formData: example_all_fields_used }
    example = { data: { id: '1234567a-89b0-123c-d456-789e01234f56', type: hlr_show_type, attributes: attrs } }

    {
      description: 'Info about a single Higher-Level Review',
      content: { 'application/json': { schema: hlr_show_schema, examples: { HlrFound: { value: example } } } }
    }
  end.call

  hlr_ci_responses = read_json_from_v1_dir['responses_contestable_issues.json']

  swagger_component do
    schema :hlrShow do
      key :type, hlr_show_schema[:type]
      key :properties, hlr_show_schema[:properties]
    end

    schema :hlrContestableIssuesShow do
      key :type, OBJ
      key :properties, hlr_ci_responses['200']['content']['application/vnd.api+json']['schema']['properties']
    end
  end

  headers_json_schema = read_json[['config', 'schemas', 'v2', '200996_headers.json']]
  headers_swagger = AppealsApi::JsonSchemaToSwaggerConverter.new(headers_json_schema).to_swagger
  header_schemas = headers_swagger['components']['schemas']
  headers = header_schemas['hlrCreateParameters']['properties'].keys
  hlr_create_parameters = headers.map do |header|
    header_def = header_schemas['hlrCreateParameters']['properties'][header]
    {
      name: header,
      in: 'header',
      description: header_def['description'] || header_def&.dig('allOf')&.send(:[], 0)&.dig('description'),
      required: header_schemas['hlrCreateParameters']['required'].include?(header)
    }
  end

  hlr_create_json_schema = read_json[['config', 'schemas', 'v2', '200996.json']]

  hlr_create_request_body = AppealsApi::JsonSchemaToSwaggerConverter.new(
    hlr_create_json_schema
  ).to_swagger['requestBody']

  hlr_create_request_body['content']['application/json']['examples'] = {
    'minimum fields used': { value: read_json[['spec', 'fixtures', 'valid_200996_minimum_v2.json']] },
    'all fields used': { value: example_all_fields_used }
  }

  swagger_path '/higher_level_reviews' do
    operation :post, tags: HLR_TAG do
      key :operationId, 'postHigherLevelReviews'
      key :summary, 'Creates a new Higher-Level Review.'
      desc = 'Submits a Decision Review request of type *Higher-Level Review*. This endpoint is the same as ' \
             'submitting [VA Form 20-0996](https://www.vba.va.gov/pubs/forms/VBA-20-0996-ARE.pdf) via mail or fax.'
      key :description, desc
      key :parameters, hlr_create_parameters
      key :requestBody, hlr_create_request_body
      key :responses, '200': response_hlr_show_success, '422': response_hlr_create_error
      security do
        key :apikey, []
      end
    end
  end

  swagger_path '/higher_level_reviews/{uuid}' do
    operation :get, tags: HLR_TAG do
      key :operationId, 'getHigherLevelReview'
      key :summary, 'Shows a specific Higher-Level Review. (a.k.a. the Show endpoint)'
      key :description, 'Returns all of the data associated with a specific Higher-Level Review.'
      parameter name: 'uuid', in: 'path', required: true, description: 'Higher-Level Review UUID' do
        schema { key :$ref, :uuid }
      end
      key :responses, '200': response_hlr_show_success, '404': response_hlr_show_not_found
      security do
        key :apikey, []
      end
    end
  end

  swagger_path '/higher_level_reviews/contestable_issues/{benefit_type}' do
    operation :get, tags: HLR_TAG do
      key :operationId, 'getContestableIssues'
      key :summary, 'Returns all contestable issues for a specific veteran.'
      desc = 'Returns all issues associated with a Veteran that have not previously been decided by a Higher-Level ' \
             'Review as of the `receiptDate` and bound by `benefitType`. Not all issues returned are guaranteed to be ' \
             'eligible for appeal. Associate these results when creating a new Higher-Level Review.'
      key :description, desc

      parameter name: 'X-VA-SSN', in: 'header', description: 'Veteran\'s ssn' do
        key :description, 'Either X-VA-SSN or X-VA-File-Number is required'
        schema type: :string, format: '^[0-9]{9}$'
      end
      parameter name: 'X-VA-File-Number', in: 'header', description: 'Veteran\'s file number' do
        key :description, 'Either X-VA-SSN or X-VA-File-Number is required'
        schema type: :string
      end
      parameter name: 'X-VA-Receipt-Date', in: 'header', required: true do
        desc = '(yyyy-mm-dd) In order to determine contestability of issues, ' \
               'the receipt date of a hypothetical Decision Review must be specified.'
        key :description, desc
        schema type: :string, format: :date
      end
      parameter name: 'benefit_type', in: 'path', required: true, description: 'Benefit Type' do
        schema type: :string, enum: ['compensation']
      end

      # All types, for reference: %w[compensation pension fudiciary insurance education voc_rehab loan_guaranty vha nca]
      detail = 'Benefit type nil is invalid. Must be one of: ["compensation"]'
      hlr_ci_responses['422']['content']['application/vnd.api+json']['examples']['invalid benefit_type'] = {
        value: {
          errors: [{ status: 422, code: 'invalid_benefit_type', title: 'Invalid Benefit Type', detail: detail }]
        }
      }
      key :responses, hlr_ci_responses

      security do
        key :apikey, []
      end
    end
  end

  swagger_path '/higher_level_reviews/schema' do
    operation :get, tags: HLR_TAG do
      key :operationId, 'getHigherLevelReviewSchema'
      key :summary, 'Gets the Higher-Level Review JSON Schema.'
      desc = 'Returns the [JSON Schema](https://json-schema.org/) for the `POST /higher_level_reviews` endpoint.'
      key :description, desc
      response '200' do
        key :description, 'the JSON Schema for POST /higher_level_reviews'
        schema = JSON.pretty_generate AppealsApi::JsonSchemaToSwaggerConverter.remove_comments(hlr_create_json_schema)
        key :content, 'application/json': { examples: { default: { value: schema } } }
      end
      security do
        key :apikey, []
      end
    end
  end

  swagger_path '/higher_level_reviews/validate' do
    operation :post, tags: HLR_TAG do
      key :operationId, 'postValidateHigherLevelReview'
      key :summary, 'Validates a POST request body against the JSON schema.'
      desc = 'Like the `POST /higher_level_reviews`, but *only* does the validations **—does not submit anything.**'
      key :description, desc
      key :parameters, hlr_create_parameters
      key :requestBody, hlr_create_request_body
      type = { type: :string, enum: [:higherLevelReviewValidation] }
      attrs = { type: OBJ, properties: { status: { type: :string, enum: [:valid] } } }
      example = { data: { type: type[:enum].first, attributes: { status: :valid } } }
      schema = { type: OBJ, properties: { data: { type: OBJ, properties: { type: type, attributes: attrs } } } }
      content = { 'application/json': { schema: schema, examples: { valid: { value: { data: example } } } } }
      key :responses, '200': { description: 'Valid', content: content }, '422': response_hlr_create_error
      security do
        key :apikey, []
      end
    end
  end
end
