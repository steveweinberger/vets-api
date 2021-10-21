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

      response '202', 'Accepted. Location generated.' do
        schema JSON.parse(File.read(VBADocuments::Engine.root.join('spec', 'support', 'schemas',
                                                                   'document_upload_path.json')))

        let (:uuid) { FactoryBot.create(:upload_submission).guid }

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


  end
end
