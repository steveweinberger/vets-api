require 'swagger_helper'
require_relative '../../support/vba_document_fixtures'
require Rails.root.join('spec', 'rswag_override.rb').to_s
require 'rails_helper'

describe 'Show', swagger_doc: 'modules/vba_documents/app/swagger/vba_documents/v1/swagger.json', type: :request do
  include VBADocuments::Fixtures

  path '/uploads/{id}' do

    let(:apikey) { 'apikey' }
    let(:upload) { FactoryBot.create(:upload_submission, :status_uploaded) }

    get 'Get status for a previous benefits document upload' do
      tags 'VBA Documents'

      operationId 'showSubmission'

      security [
                 { apikey: [] }
               ]

      produces 'application/json'

      parameter name: :id,
                example: '6d8433c1-cd55-4c24-affd-f592287a7572',
                required: true,
                in: :path,
                description: 'ID as returned by a previous create upload request',
                schema: {
                  type: :string,
                  format: "uuid"
                }

      describe 'Getting a 200 response' do
        response '200', 'Get status for a previous benefits document upload' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref': '#/components/schemas/DocumentUploadStatus'
                   }
                 },
                 required: ['data']

          let(:id) { upload.guid }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a 200 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
        end
      end

      describe 'Getting a 401 response' do
        response '401', 'Unauthorized Request' do
          schema type: :object,
                 required: %w[message],
                 properties: {
                   message: {
                     type: :string,
                     example: 'Invalid authentication credentials',
                     minLength: 0,
                     maxLength: 1000,
                     description: 'Error detail'
                   }
                 }
          let(:id) { upload.guid }

          before do |example|
            allow_any_instance_of(VBADocuments::V1::UploadsController)
              .to receive(:get_response_object_show).and_return ({ status: :unauthorized,
                                                                     json: { message: "Invalid authentication credentials"}})

            submit_request(example.metadata)
          end

          it 'returns a 401 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            puts response
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
              }
            }
          end
        end
      end

      describe 'Getting a 403 response' do
        response '403', 'Forbidden' do
          schema type: :object,
                 required: %w[message],
                 properties: {
                   message: {
                     type: :string,
                     example: 'You cannot consume this service',
                     minLength: 0,
                     maxLength: 1000,
                     description: 'Error detail'
                   }
                 }
          let(:id) { upload.guid }

          before do |example|
            allow_any_instance_of(VBADocuments::V1::UploadsController)
              .to receive(:get_response_object_show).and_return ({ status: :forbidden,
                                                                     json: { message: "You cannot consume this service"}})

            submit_request(example.metadata)
          end

          it 'returns a 403 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            puts response
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
              }
            }
          end
        end
      end

      describe 'Getting a 404 response' do
        response '404', 'Unprocessable Entity' do
          schema type: :object,
                 required: %w[errors],
                 properties: {
                   errors: {
                     type: :array,
                     minItems: 1,
                     maxItems: 1000,
                     items: {
                       '$ref': '#/components/schemas/ErrorModel'
                     }
                   }
                 }

          let(:id) { 'invalid' }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a 404 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            puts response
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
              }
            }
          end
        end
      end

      describe 'Getting a 429 response' do
        response '429', 'Too many requests' do
          schema type: :object,
                 required: %w[message],
                 properties: {
                   message: {
                     type: :string,
                     example: "API rate limit exceeded",
                     minLength: 0,
                     maxLength: 1000
                   }
                 }
          let(:id) { upload.guid }

          before do |example|
            allow_any_instance_of(VBADocuments::V1::UploadsController)
              .to receive(:get_response_object_show).and_return ({ status: 429,
                                                                     json: { message: "API rate limit exceeded"}})

            submit_request(example.metadata)
          end

          it 'returns a 429 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            puts response
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
              }
            }
          end
        end
      end

      describe 'Getting a 500 response' do
        response '500', 'Internal server error' do
          schema type: :object,
                 required: %w[code title detail status],
                 properties: {
                   code: {
                     type: :string,
                     minLength: 3,
                     maxLength: 3,
                     pattern: "500"
                   },
                   title: {
                     type: :string,
                     minLength: 21,
                     maxLength: 21,
                     pattern: "Internal server error"
                   },
                   detail: {
                     type: :string,
                     minLength: 21,
                     maxLength: 21,
                     pattern: "Internal server error"
                   },
                   status: {
                     type: :string,
                     minLength: 3,
                     maxLength: 3,
                     pattern: "500"
                   },
                 }
          let(:id) { upload.guid }

          before do |example|
            allow_any_instance_of(VBADocuments::V1::UploadsController)
              .to receive(:get_response_object_show).and_return ({ status: :internal_server_error,
                                                                     json: { code: "500", title: "Internal server error", detail: "Internal server error", status: "500"}})

            submit_request(example.metadata)
          end

          it 'returns a 500 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            puts response
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
              }
            }
          end
        end
      end
    end
  end
end
