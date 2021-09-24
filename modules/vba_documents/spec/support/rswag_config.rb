# rspec --pattern modules/vba_documents/spec/requests/\*\*/\*_spec.rb --format Rswag::Specs::SwaggerFormatter --order defined
class VBADocuments::RswagConfig
  def config
    {
      'modules/vba_documents/app/swagger/vba_documents/v2/swagger.json' => {
        openapi: '3.0.1',
        info: {
          title: 'Benefits Intake',
          version: 'v1',
          termsOfService: 'https://developer.va.gov/terms-of-service',
          description: 'example description', #File.read(AppealsApi::Engine.root.join('app', 'swagger', 'vba_documents', 'v1', 'description.md'))
        },
        tags: [
          {
            name: 'Benefits Intake',
            description: 'VA Benefits document upload functionality'
          }
        # ^ These tags are used for grouping each individual endpoint in the swagger UI
        ],
        components: {
          securitySchemes: {
            # ^ add your relevant security schemes here
            apikey: {
              type: :apiKey,
              name: :apikey,
              in: :header
            }
          },
          schemas: {
            # ^ schemas that can be used across multiple Rswag specs
            'nonBlankString': {
              'type': 'string',
              'pattern': '[^ \\f\\n\\r\\t\\v\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\ufeff]'
              #'$comment': "The pattern used ensures that a string has at least one non-whitespace character. The pattern comes from JavaScript's \\s character class. \"\\s Matches a single white space character, including space, tab, form feed, line feed, and other Unicode spaces. Equivalent to [ \\f\\n\\r\\t\\v\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\ufeff].\": https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions/Character_Classes  We are using simple character classes at JSON Schema's recommendation: https://tools.ietf.org/html/draft-handrews-json-schema-validation-01#section-4.3"
            }
          }
        },
        paths: {},
        basePath: '/services/vba_documents/v2',
        # ^ basePath is used in building up the url that Rswag will use in testing
        servers: [
          # ^ Used in creating the 'Environment' drop-down for generating example curl commands
          {
            url: 'https://dev-api.va.gov/services/vba_documents/{version}/',
            description: 'VA.gov API sandbox environment',
            variables: {
              version: {
                default: 'v1'
              }
            }
          }
        ]
      }
    }
  end
end