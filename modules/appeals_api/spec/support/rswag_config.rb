# frozen_string_literal: true

class AppealsApi::RswagConfig
  def config # rubocop:disable Metrics/MethodLength
    {
    #   'modules/appeals_api/app/swagger/appeals_api/v1/swagger.json' => {
    #     openapi: '3.0.0',
    #     info: {
    #       title: 'Decision Reviews',
    #       version: 'v1',
    #       termsOfService: 'https://developer.va.gov/terms-of-service',
    #       description: <<~VERBIAGE
    #         ### v1 Description
    #         details here...
    #       VERBIAGE
    #     },
    #     tags: [
    #       {
    #         name: 'Higher-Level Reviews',
    #         description: ''
    #       },
    #       {
    #         name: 'Notice of Disagreements',
    #         description: ''
    #       }
    #     ],
    #     components: {
    #       securitySchemes: {
    #         apikey: {
    #           type: :apiKey,
    #           name: :apikey,
    #           in: :header
    #         },
    #       }
    #     },
    #     paths: {},
    #     basePath: '/services/appeals/v1/decision_reviews',
    #     servers: [
    #       {
    #         url: 'https://dev-api.va.gov/services/appeals/{version}/decision_reviews',
    #         description: 'VA.gov API sandbox environment',
    #         variables: {
    #           version: {
    #             default: 'v1'
    #           }
    #         }
    #       }
    #     ]
    #   }
      'modules/appeals_api/app/swagger/appeals_api/v2/swagger.json' => {
        openapi: '3.0.0',
        info: {
          title: 'Decision Reviews',
          version: 'v2',
          termsOfService: 'https://developer.va.gov/terms-of-service',
          description: File.read(AppealsApi::Engine.root.join('app', 'swagger', 'appeals_api', 'v2', 'api_description.md'))
        },
        tags: [
          {
            name: 'Higher-Level Reviews',
            description: ''
          },
          {
            name: 'Notice of Disagreements',
            description: ''
          }
        ],
        components: {
          securitySchemes: {
            apikey: {
              type: :apiKey,
              name: :apikey,
              in: :header
            },
          },
          schemas: {
            higherLevelReview: JSON.parse(File.read(AppealsApi::Engine.root.join('config', 'schemas', 'v2', '200996.json')))
          }
        },
        paths: {},
        basePath: '/services/appeals/v2/decision_reviews',
        servers: [
          {
            url: 'https://sandbox-api.va.gov/services/appeals/{version}/decision_reviews',
            description: 'VA.gov API sandbox environment',
            variables: {
              version: {
                default: 'v2'
              }
            }
          },
          {
            url: 'https://api.va.gov/services/appeals/{version}/decision_reviews',
            description: 'VA.gov API production environment',
            variables: {
              version: {
                default: 'v2'
              }
            }
          }
        ]
      }
    }
  end
end
