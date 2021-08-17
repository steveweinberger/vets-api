# frozen_string_literal: true

require 'swagger_helper'
require Rails.root.join('spec', 'rswag_override.rb').to_s

require 'rails_helper'
require_relative '../../support/swagger_shared_components'

# rubocop:disable RSpec/VariableName, RSpec/ScatteredSetup, RSpec/RepeatedExample, Layout/LineLength, RSpec/RepeatedDescription

describe 'Notice of Disagreements', swagger_doc: 'modules/appeals_api/app/swagger/appeals_api/v2/swagger.json', type: :request do
  let(:apikey) { 'apikey' }

  path '/notice_of_disagreements' do
    post 'Creates a new Notice of Disagreement' do
      tags 'Notice of Disagreements'
      operationId 'createNod'
      description 'Submits an appeal of type Notice of Disagreement.' \
      ' This endpoint is the same as submitting [VA Form 10182](https://www.va.gov/vaforms/va/pdf/VA10182.pdf)' \
      ' via mail or fax directly to the Board of Veterans’ Appeals.'

      security [
        { apikey: [] }
      ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :nod_body, in: :body, schema: { '$ref' => '#/components/schemas/nodCreateRoot' }

      parameter in: :body, examples: {
        'minimum fields used' => {
          value: JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
        },
        'all fields used' => {
          value: JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
        }
      }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_ssn_header]
      let(:'X-VA-SSN') { '000000000' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_first_name_header]
      let(:'X-VA-First-Name') { 'first' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_middle_initial_header]

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_last_name_header]
      let(:'X-VA-Last-Name') { 'last' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_birth_date_header]
      let(:'X-VA-Birth-Date') { '1900-01-01' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_file_number_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_username_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_id_header]

      response '200', 'Info about a single Notice of Disagreement' do
        let(:nod_body) do
          JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
        end

        schema AppealsApi::SwaggerSharedComponents.response_schemas[:nod_response_schema]

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'minimum fields used' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '200', 'Info about a single Notice of Disagreement' do
        let(:nod_body) do
          JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
        end

        schema AppealsApi::SwaggerSharedComponents.response_schemas[:nod_response_schema]

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'all fields used' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '422', 'Violates JSON schema' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors',
                                                                 'default.json')))
        let(:nod_body) do
          request_body = JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
          request_body['data']['attributes'].delete('socOptIn')
          request_body
        end

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        it 'returns a 422 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path '/notice_of_disagreements/{uuid}' do
    get 'Shows a specific Notice of Disagreement. (a.k.a. the Show endpoint)' do
      tags 'Notice of Disagreements'
      operationId 'showNod'
      description 'Returns all of the data associated with a specific Notice of Disagreement.'

      security [
        { apikey: [] }
      ]
      produces 'application/json'

      parameter name: :uuid, in: :path, type: :string, description: 'Notice of Disagreement UUID'

      response '200', 'Info about a single Notice of Disagreement' do
        schema AppealsApi::SwaggerSharedComponents.response_schemas[:nod_response_schema]

        nod = FactoryBot.create(:minimal_notice_of_disagreement)
        let(:uuid) { nod.id }

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        it 'returns a 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'Notice of Disagreement not found' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', '404.json')))

        let(:uuid) { 'invalid' }

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        it 'returns a 404 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path '/notice_of_disagreements/schema' do
    get 'Gets the Notice of Disagreement JSON Schema.' do
      tags 'Notice of Disagreements'
      operationId 'nodSchema'
      description 'Returns the JSON Schema for the POST /notice_of_disagreements endpoint.'
      security [
        { apikey: [] }
      ]
      produces 'application/json'

      response '200', 'the JSON Schema for POST /notice_of_disagreements' do
        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        it 'returns a 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end

  path '/notice_of_disagreements/validate' do
    post 'Validates a POST request body against the JSON schema.' do
      tags 'Notice of Disagreements'
      operationId 'nodValidate'
      description 'Like the POST /notice_of_disagreements, but only does the validations <b>—does not submit anything.</b>'
      security [
        { apikey: [] }
      ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :nod_body, in: :body, schema: { '$ref' => '#/components/schemas/nodCreateRoot' }

      parameter in: :body, examples: {
        'minimum fields used' => {
          value: JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
        },
        'all fields used' => {
          value: JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
        }
      }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_ssn_header]
      let(:'X-VA-SSN') { '000000000' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_first_name_header]
      let(:'X-VA-First-Name') { 'first' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_middle_initial_header]

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_last_name_header]
      let(:'X-VA-Last-Name') { 'last' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_birth_date_header]
      let(:'X-VA-Birth-Date') { '1900-01-01' }

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_file_number_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_username_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_id_header]

      response '200', 'Valid' do
        let(:nod_body) do
          JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
        end

        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'nod_validate.json')))

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'minimum fields used' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '200', 'Info about a single Notice of Disagreement' do
        let(:nod_body) do
          JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
        end

        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'nod_validate.json')))

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'all fields used' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '422', 'Error' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', 'default.json')))

        let(:nod_body) do
          request_body = JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
          request_body['data']['attributes'].delete('socOptIn')
          request_body
        end

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'Violates JSON schema' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '422', 'Error' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors',
                                                                 'not_json.json')))
        let(:nod_body) do
          nil
        end

        before do |example|
          submit_request(example.metadata)
        end

        after do |example|
          response_title = example.metadata[:description]
          example.metadata[:response][:content] = {
            'application/json' => {
              examples: {
                "#{response_title}": {
                  value: JSON.parse(response.body, symbolize_names: true)
                }
              }
            }
          }
        end

        it 'Not JSON object' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
# rubocop:enable RSpec/VariableName, RSpec/ScatteredSetup, RSpec/RepeatedExample, Layout/LineLength, RSpec/RepeatedDescription
