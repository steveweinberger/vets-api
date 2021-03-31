require_relative '../../../swagger_helper'

RSpec.describe 'claims_api/v1/claims', type: :request, swagger_doc: 'v1/swagger.json' do
  path '/services/claims/v1/claims' do
    get 'Retrieves all claims for a Veteran' do
      tags 'Claims'
      produces 'application/json'

      response '200', 'blog found' do
        schema_path = Rails.root.join('spec', 'support', 'schemas_camelized', "claims_api/claims.json")
        uri = JSON::Util::URI.file_uri(schema_path.to_s)
        body = File.read(JSON::Util::URI.unescaped_path(Pathname.new(uri.path).expand_path.to_s))
        body = JSON::Schema.new(JSON::Validator.parse(body), uri)
        schema body.schema

        let(:scopes) { %w[claim.read] }

        parameter({
          in: :header,
          type: :string,
          name: 'X-VA-SSN',
          required: false,
          description: 'Veteran SSN if consumer is representative'
        })
        let(:'X-VA-SSN') { '796-04-3735' }
        parameter({
          in: :header,
          type: :string,
          name: 'X-VA-First-Name',
          required: false,
          description: 'Veteran first name if consumer is representative'
        })
        let(:'X-VA-First-Name') { 'WESLEY' }
        parameter({
          in: :header,
          type: :string,
          name: 'X-VA-Last-Name',
          required: false,
          description: 'Veteran last name if consumer is representative'
        })
        let(:'X-VA-Last-Name') { 'FORD' }
        parameter({
          in: :header,
          type: :string,
          name: 'X-VA-Birth-Date',
          required: false,
          description: 'Veteran birthdate if consumer is representative'
        })
        let(:'X-VA-Birth-Date') { '1986-05-06T00:00:00+00:00' }
        parameter({
          in: :header,
          type: :string,
          name: 'X-Key-Inflection',
          required: false,
          description: 'Choose desired key structure for response'
        })
        let(:'X-Key-Inflection') { 'camel' }
        parameter({
          in: :header,
          type: :string,
          name: 'Authorization',
          required: true,
          description: 'OAuth token'
        })
        let(:'Authorization') { 'Bearer token' }

        before do |example|
          stub_poa_verification
          stub_mpi

          with_okta_user(scopes) do |auth_header|
            VCR.use_cassette('evss/claims/claims') do
              submit_request(example.metadata)
            end
          end
        end

        it 'returns a valid 200 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end
      end
    end
  end
end
