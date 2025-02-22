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

        schema '$ref' => '#/components/schemas/nodCreateResponse'

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
            }
          }
        end
      end

      response '200', 'Info about a single Notice of Disagreement' do
        let(:nod_body) do
          JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
        end

        schema '$ref' => '#/components/schemas/nodCreateResponse'

        before do |example|
          submit_request(example.metadata)
        end

        it 'all fields used' do |example|
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
            }
          }
        end
      end

      response '422', 'Violates JSON schema' do
        schema '$ref' => '#/components/schemas/errorModel'

        let(:nod_body) do
          request_body = JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182.json')))
          request_body['data']['attributes'].delete('socOptIn')
          request_body
        end

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 422 response' do |example|
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
        schema '$ref' => '#/components/schemas/nodCreateResponse'

        let(:uuid) { FactoryBot.create(:minimal_notice_of_disagreement).id }

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

      response '404', 'Notice of Disagreement not found' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', '404.json')))

        let(:uuid) { 'invalid' }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 404 response' do |example|
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
  end

  path '/notice_of_disagreements/schema' do
    get 'Gets the Notice of Disagreement JSON Schema.' do
      tags 'Notice of Disagreements'
      operationId 'nodSchema'
      description 'Returns the [JSON Schema](https://json-schema.org/) for the `POST /notice_of_disagreement` endpoint.'
      security [
        { apikey: [] }
      ]
      produces 'application/json'

      response '200', 'the JSON Schema for POST /notice_of_disagreements' do
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
            }
          }
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

        it 'all fields used' do |example|
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
            }
          }
        end
      end

      response '422', 'Error' do
        schema '$ref' => '#/components/schemas/errorModel'

        let(:nod_body) do
          request_body = JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'fixtures', 'valid_10182_minimum.json')))
          request_body['data']['attributes'].delete('socOptIn')
          request_body
        end

        before do |example|
          submit_request(example.metadata)
        end

        it 'Violates JSON schema' do |example|
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
            }
          }
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

        it 'Not JSON object' do |example|
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
            }
          }
        end
      end
    end
  end

  path '/notice_of_disagreements/evidence_submissions/' do
    post 'Get a location for subsequent evidence submission document upload PUT request' do
      tags 'Notice of Disagreements'
      operationId 'postNoticeOfDisagreementEvidenceSubmission'
      description <<~DESC
        This is the first step to submitting supporting evidence for an NOD.  (See the Evidence Uploads section above for additional information.)
        The Notice of Disagreement GUID that is returned when the NOD is submitted, is supplied to this endpoint to ensure the NOD is in a valid state for sending supporting evidence documents.  Only NODs that selected the Evidence Submission lane are allowed to submit evidence documents up to 90 days after the NOD is received by VA.
      DESC

      parameter name: :nod_uuid, in: :query, type: :string, required: true, description: 'Associated Notice of Disagreement UUID'

      parameter AppealsApi::SwaggerSharedComponents.header_params[:veteran_ssn_header]
      let(:'X-VA-SSN') { '123456789' }

      security [
        { apikey: [] }
      ]
      produces 'application/json'

      response '202', 'Accepted. Location generated' do
        let(:nod_uuid) { FactoryBot.create(:minimal_notice_of_disagreement, board_review_option: 'evidence_submission').id }

        schema '$ref' => '#/components/schemas/evidenceSubmissionResponse'

        before do |example|
          allow_any_instance_of(VBADocuments::UploadSubmission).to receive(:get_location).and_return(+'http://some.fakesite.com/path/uuid')
          submit_request(example.metadata)
        end

        it 'returns a 202 response' do |example|
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

      response '400', 'Bad Request' do
        let(:nod_uuid) { nil }

        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: {
                     properties: {
                       status: {
                         type: 'integer',
                         example: 400
                       },
                       detail: {
                         type: 'string',
                         example: 'Must supply a corresponding NOD id in order to submit evidence'
                       }
                     }
                   }
                 }
               }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 400 response' do |example|
          # NOOP
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
      end

      response '404', 'Associated Notice of Disagreement not found' do
        let(:nod_uuid) { nil }

        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: {
                     properties: {
                       status: {
                         type: 'integer',
                         example: 404
                       },
                       detail: {
                         type: 'string',
                         example: 'The record identified by {nod_uuid} not found.'
                       }
                     }
                   }
                 }
               }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 404 response' do |example|
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

      response '422', 'Validation errors' do
        let(:nod_uuid) { FactoryBot.create(:minimal_notice_of_disagreement, board_review_option: 'evidence_submission').id }
        let(:'X-VA-SSN') { '000000000' }

        schema '$ref' => '#/components/schemas/errorModel'

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 422 response' do |example|
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

      response '500', 'Unknown Error' do
        let(:nod_uuid) { nil }

        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: {
                     properties: {
                       status: {
                         type: 'integer',
                         example: 500
                       },
                       detail: {
                         type: 'string',
                         example: 'An unknown error has occurred.'
                       },
                       code: {
                         type: 'string',
                         example: '151'
                       },
                       title: {
                         type: 'string',
                         example: 'Internal Server Error'
                       }
                     }
                   }
                 },
                 status: {
                   type: 'integer',
                   example: 500
                 }
               }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 500 response' do |example|
          # NOOP
        end
      end
    end
  end

  path '/path' do
    put 'Accepts Notice of Disagreement Evidence Submission document upload.' do
      tags 'Notice of Disagreements'
      operationId 'putNoticeOfDisagreementEvidenceSubmission'
      description File.read(AppealsApi::Engine.root.join('app', 'swagger', 'appeals_api', 'v1', 'put_description.md'))

      parameter name: :'Content-MD5', in: :header, type: :string, description: 'Base64-encoded 128-bit MD5 digest of the message. Use for integrity control.'
      let(:'Content-MD5') { nil }

      response '200', 'Document upload staged' do
        it 'returns a 200 response' do |example|
          # noop
        end
      end

      response '400', 'Document upload failed' do
        produces 'application/xml'

        schema type: :object,
               description: 'Document upload failed',
               xml: { 'name': 'Error' },
               properties: {
                 Code: {
                   type: :string, description: 'Error code', example: 'Bad Digest'
                 },
                 Message: {
                   type: :string, description: 'Error detail',
                   example: 'A client error (InvalidDigest) occurred when calling the PutObject operation - The Content-MD5 you specified was invalid.'
                 },
                 Resource: {
                   type: :string, description: 'Resource description', example: '/example_path_here/6d8433c1-cd55-4c24-affd-f592287a7572.upload'
                 },
                 RequestId: {
                   type: :string, description: 'Identifier for debug purposes'
                 }
               }

        it 'returns a 400 response' do |example|
          # noop
        end
      end
    end
  end

  path '/notice_of_disagreements/evidence_submissions/{uuid}' do
    get 'Returns all of the data associated with a specific Notice of Disagreement Evidence Submission.' do
      tags 'Notice of Disagreements'
      operationId 'getNoticeOfDisagreementEvidenceSubmission'
      description 'Returns all of the data associated with a specific Notice of Disagreement Evidence Submission.'

      security [
        { apikey: [] }
      ]
      produces 'application/json'

      parameter name: :uuid, in: :path, type: :string, description: 'Notice of Disagreement UUID Evidence Submission'

      response '200', 'Info about a single Notice of Disagreement Evidence Submission.' do
        schema '$ref' => '#/components/schemas/evidenceSubmissionResponse'

        let(:uuid) { FactoryBot.create(:evidence_submission).guid }

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

      response '404', 'Notice of Disagreement Evidence Submission not found' do
        schema JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'errors', '404.json')))

        let(:uuid) { 'invalid' }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 404 response' do |example|
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
  end
end
# rubocop:enable RSpec/VariableName, RSpec/ScatteredSetup, RSpec/RepeatedExample, Layout/LineLength, RSpec/RepeatedDescription
