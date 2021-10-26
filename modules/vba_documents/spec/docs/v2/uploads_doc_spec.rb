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
      #
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
                   Message: {
                     type: :string,
                     example: 'Invalid authentication credentials',
                     minLength: 0,
                     maxLength: 1000,
                     description: 'Error detail'
                   }
                 }

          before do |example|
            allow_any_instance_of(VBADocuments::V2::UploadsController)
              .to receive(:create).and_return(ApplicationController.render status: 401,
                                                     json: { message: "Invalid authentication credentials"})
            submit_request(example.metadata)
          end

          it 'returns a 401 response' do |example|
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
    end
  end
end
