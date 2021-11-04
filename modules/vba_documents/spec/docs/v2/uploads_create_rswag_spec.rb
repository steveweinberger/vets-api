require 'swagger_helper'
require Rails.root.join('spec', 'rswag_override.rb').to_s
require 'rails_helper'

describe 'uploads', swagger_doc: 'modules/vba_documents/app/swagger/vba_documents/v2/swagger.json', type: :request do
  path '/uploads' do

    let (:apikey) {'apikey'}

    post 'Get a location for subsequent document upload PUT request' do
      tags 'VBA Documents'
      operationId 'createSubmission'
      security [
                 { apikey: []}
               ]
      produces 'application/json'
      # parameter name: param_name, in: :path, type: :string, description: 'Param Description'

      describe 'Getting a 200 response' do
        response '202', 'Accepted. Location generated.' do
          schema type: :object,
                 properties: {
                   data: {
                     '$ref': '#/components/schemas/DocumentUploadPath'
                   }
                 }

          before do |example|
            submit_request(example.metadata)
          end

          it 'returns a 202 response' do |example|
            assert_response_matches_metadata(example.metadata)
          end

          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names:true)
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

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:get_response_object_create).and_return ({ status: :unauthorized,
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

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:get_response_object_create).and_return ({ status: :forbidden,
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

      describe 'Getting a 422 response' do
        response '422', 'Unprocessable Entity' do
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

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:create).and_raise(Common::Exceptions::UnprocessableEntity.new(detail: "DOC104 - Upload rejected by upstream system. Processing failed and upload must be resubmitted"))

            submit_request(example.metadata)
          end

          it 'returns a 422 response' do |example|
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

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:get_response_object_create).and_return ({ status: 429,
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

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:get_response_object_create).and_return ({ status: :internal_server_error,
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
