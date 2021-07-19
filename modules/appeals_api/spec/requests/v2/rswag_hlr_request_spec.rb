# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'
require_relative '../../support/swagger_shared_components'

describe 'Higher-Level Reviews', swagger_doc: 'modules/appeals_api/app/swagger/appeals_api/v2/swagger.json' do  # rubocop:disable RSpec/DescribeClass

  let(:apikey) { 'apikey' }

  path '/higher_level_reviews' do

    post 'Creates a new Higher-Level Review' do
      tags 'Higher-Level Reviews'
      operationId 'createHlr'
      security [
        { apikey: [] }
      ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :hlr_body, in: :body, schema: { '$ref' => '#/components/schemas/higherLevelReview' }

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
      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_insurance_policy_number_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_username_header]
      parameter AppealsApi::SwaggerSharedComponents.header_params[:consumer_id_header]

      response '200', 'Info about a single Higher-Level Review' do
        let(:hlr_body) { JSON.parse(File.read(AppealsApi::Engine.root.join('spec','fixtures','valid_200996_v2.json'))) }

        schema type: :object,
          properties: {
            id: {
              type: :string,
              pattern: '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$'
            },
            type: {
              type: :string,
              enum: ['higherLevelReview']
            },
            attributes: {
              properties: {
                status: {
                  type: :string,
                  enum: AppealsApi::HlrStatus::V2_STATUSES
                },
                updatedAt: {
                  type: :string,
                  pattern: '\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}\.\d{3}Z'
                },
                createdAt: {
                  type: :string,
                  pattern: '\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}\.\d{3}Z'
                },
                formData: {
                  '$ref' => '#/components/schemas/higherLevelReview'
                }
              }
            }
          }

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

      response '422', 'Violates JSON schema' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', 'default.json')))
        let(:hlr_body) do
          request_body = JSON.parse(File.read(AppealsApi::Engine.root.join('spec','fixtures','valid_200996_v2.json')))
          request_body['data']['attributes'].delete('informalConference')
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

  path '/higher_level_reviews/{uuid}' do

    get 'Shows a specific Higher-Level Review. (a.k.a. the Show endpoint)' do
      tags 'Higher-Level Reviews'
      operationId 'showHlr'
      security [
        { apikey: [] }
      ]
      produces 'application/json'

      parameter name: :uuid, in: :path, type: :string, description: 'Higher-Level Review UUID'

      response '200', 'Info about a single Higher-Level Review' do

        schema type: :object,
          properties: {
            id: {
              type: :string,
              pattern: '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$'
            },
            type: {
              type: :string,
              enum: ['higherLevelReview']
            },
            attributes: {
              properties: {
                status: {
                  type: :string,
                  enum: AppealsApi::HlrStatus::V2_STATUSES
                },
                updatedAt: {
                  type: :string,
                  pattern: '\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}\.\d{3}Z'
                },
                createdAt: {
                  type: :string,
                  pattern: '\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}\.\d{3}Z'
                },
                formData: {
                  '$ref' => '#/components/schemas/higherLevelReview'
                }
              }
            }
          }

        hlr = FactoryBot.create(:higher_level_review)
        let(:uuid) { hlr.id }

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

      response '404', 'Higher-Level Review not found' do

        schema type: :object,
          errors: [
            {
              status: 404,
              detail: 'HigherLevelReview with uuid "invalid" not found.'
            }
          ]

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
end
