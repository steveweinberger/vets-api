require 'swagger_helper'
# ^ standard Rswag helper
require Rails.root.join('spec', 'rswag_override.rb').to_s
# ^ Rswag overrides to allow for multiple body examples and only writing out relevant swagger json (instead of writing all swagger json files out every time Rswag is run).
require_dependency 'vba_documents/payload_manager'

require 'rails_helper'

describe 'Uploading a file', swagger_doc: 'modules/vba_documents/app/swagger/vba_documents/v2/swagger.json', type: :request do
  #                                           ^ this path needs to match one of the paths from your Rswag config
  #                                                                                                           ^ adding 'type: :request' makes sure that RSpec knows how to properly interpret your spec if it lives outside of the 'spec/requests' path


  path '/uploads/{uuid}' do
    # ^ this should be the actual url fragment you want Rswag to make a request to

    let(:apikey) { 'apikey' }
    V1_STATUSES = %w[pending submitting submitted processing error uploaded received success expired].freeze
    DOC_CODES = %w[DOC101 DOC102 DOC103 DOC104 DOC105 DOC106 DOC107 DOC108].freeze

    get 'Shows a specific Higher-Level Review. (a.k.a. the Show endpoint)' do
      tags 'Higher-Level Reviews'
      # ^ Which tag(s) should this example be nested in (from the rswag config)

      operationId 'uploads/{id}'
      # ^ unique Id that will be used by the swagger UI

      security [
                 { apikey: [] }
               ]
      # ^ relevant security schemes (from Rswag config)

      produces 'application/json'

      parameter name: :uuid, in: :path, type: :string, description: 'Higher-Level Review UUID'
      #         ^ name's value is important - it will be set by its value in the 'response' section

      response '200', 'Info about a single Higher-Level Review' do
        schema type: :object,
               properties: {
                 data: {
                   properties: {
                     id: {
                       type: :string,
                       pattern: '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$'
                     },
                     type: {
                       type: :string,
                       enum: ['document_upload']
                     },
                     attributes: {
                       properties: {
                         guid: {
                           type: :string,
                           pattern: '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$'
                         },
                         status: {
                           type: :string,
                           example: V1_STATUSES.first,
                           enum: V1_STATUSES
                         },
                         code: {
                           type: :string,
                           example: DOC_CODES.first,
                           enum: DOC_CODES
                         },
                         detail: {
                           type: :string
                         },
                        #  location: { # TODO: find out how location is returned
                        #    type: :string
                        #  },
                         updatedAt: {
                           type: :string,
                           pattern: '\d{4}(-\d{2}){2}T\d{2}(:\d{2}){2}\.\d{3}Z'
                         }
                        #  uploaded_pdf: { # TODO: upload example data
                        #    type: 
                        #  }
                       }
                     }
                   },
                   required: %w[id type attributes]
                 }
               },
               required: ['data']
        # schemas can be defined several ways:
        #   inline (as shown above):
        #       schema type: :object, ...
        #   referenced from the Rswag config:
        #       schema '$ref' => '#/components/schemas/errors_object'
        #   or loaded from plain json files:
        #       schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', '404.json')))

        # hlr = FactoryBot.create(:minimal_higher_level_review_v2)
        # let!(:hlr) { create(:minimal_higher_level_review_v2) }
        let!(:upload_submission) { create(:upload_submission, code: 'DOC101', detail: 'example detail', ) }
        # hardcodee factory properties 
        let!(:uuid) { upload_submission.guid }
        
        # ^ needs to match the parameters name otherwise you'll see a No method error for 'uuid' (or whatever your parameter is called)

        before do |example|
          submit_request(example.metadata)
          # ^ makes the actual request - using the built up url (fragment and basePath) and any parameters you have supplied
        end

        it 'returns a 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
          # ^ asserts that the respose matches the schema you have supplied
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
              # ^ saves the actual response from the 'submit_request(example.metadata)' call in the before action
            }
          }
        end
      end

      response '404', 'Higher-Level Review not found' do
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

  path '/uploads/{uuid}/download' do
    get 'downloads uploaded submission' do
      parameter name: :uuid, in: :path, type: :string, description: 'Higher-Level Review UUID'

      response '200', 'returns submission content as zipfile' do
        let!(:upload_submission) { create(:upload_submission, code: 'DOC101', detail: 'example detail', ) }
        let!(:uuid) { upload_submission.guid }
        let!(:stub_file) { double("file like object", read: 'test data') }
        let!(:temp_file) { Tempfile.new('file') }

        before do |example|
          temp_file.write('test data')
          temp_file.rewind

          allow(VBADocuments::PayloadManager).to receive(:zip).and_return(temp_file.path)
        end

        after { temp_file.close }

        run_test! do |response|
          expect(response.body).to eq('test data')
        end
      end
    end
  end

   path '/reports?ids={ids}' do
    post 'retrieve uploaded submission statuses' do
      parameter name: :ids, in: :path, type: :string, description: 'Higher-Level Review UUID'
      # todo: define schema
      response '200', 'returns submission statuses' do
        let!(:upload_submission) { create(:upload_submission, code: 'DOC101', detail: 'example detail') }
        let!(:ids) { [upload_submission_1.guid] }

        run_test!
      end
    end
  end
end