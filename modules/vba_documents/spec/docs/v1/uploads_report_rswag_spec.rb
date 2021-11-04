require 'swagger_helper'
require_relative '../../support/vba_document_fixtures'
require Rails.root.join('spec', 'rswag_override.rb').to_s
require 'rails_helper'

describe 'Report', swagger_doc: 'modules/vba_documents/app/swagger/vba_documents/v1/swagger.json', type: :request do
  let(:apikey) { 'apikey' }

  path '/uploads/report' do
    post 'Get a bulk status report for a list of previous uploads' do
      # tags, operationId, description, etc

      parameter name: :body_param, in: :body, schema: {
        type: :object,
        properties: {
          ids: {
            type: :array,
            minItems: 1,
            maxItems: 1000,
            items: {
              type: :string,
              format: 'uuid',
              pattern: '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
              example: '6d8433c1-cd55-4c24-affd-f592287a7572',
              minLength: 36,
              maxLength: 36,
              description: 'JSON API identifier'
            }
          },
        },
        additionalProperties: false,
        required: %w[ids]
      }
      # =>            ^ as stated before the value passed to the name: parameter is important as you will need to set its value later)

      parameter in: :body, examples: {
        'single guid' => {
          value: {
            ids: [
              'f7027a14-6abd-4087-b397-3d84d445f4c3'
            ]
          }
        }
      }

      response '200', 'Report' do
        let(:body_param) do
          {
            ids: [
              'f7027a14-6abd-4087-b397-3d84d445f4c3'
            ]
          }
        end
        # ^ referencing the parameter named above (:hlr_body) so Rswag knows to send this json as the body of the request

        # schema ...

        before do |example|
          submit_request(example.metadata)
        end

        it 'minimum fields used' do |example|
          assert_response_matches_metadata(example.metadata)
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
              # ^ To have multiple responses (shown in the swagger UI via a drop down) you have to nest them under 'examples' instead of directly in 'example'
              #   You can set the text statically here or use the examples metadata from the 'it ... do' - in this case 'minimum fields used'. Providing that you don't over write it with a subsequent example.
            }
          }
        end
      end
    end
  end
end
