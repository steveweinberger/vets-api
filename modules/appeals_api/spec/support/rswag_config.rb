# frozen_string_literal: true

class AppealsApi::RswagConfig
  def write_schema
    rswag_hlr_v2_schema = config['modules/appeals_api/app/swagger/appeals_api/v2/swagger.json'][:components][:schemas]
    # Rswag expects schemas to live in #/components/schemas
    # Our controller validation logic expects them to live at #/definitions so we're translating them here...
    hlr_v2_schema = JSON.parse(rswag_hlr_v2_schema.to_json.gsub('#/components/schemas', '#/definitions'))
    schema = {
      '$schema': 'http://json-schema.org/draft-07/schema#',
      'description': 'JSON Schema for VA Form 20-0996',
      '$ref': '#/definitions/hlrCreate',
      'definitions': {
        'nonBlankString': hlr_v2_schema['nonBlankString'],
        'date': hlr_v2_schema['date'],
        'hlrCreatePhone': hlr_v2_schema['hlrCreatePhone'],
        'hlrCreate': hlr_v2_schema['hlrCreate']
      }
    }
    file_path = AppealsApi::Engine.root.join('config', 'schemas', 'v2', '200996.json')
    File.open(file_path, 'w') do |f|
      f.write(JSON.pretty_generate(schema))
    end
  end

  # rubocop:disable Metrics/MethodLength, Layout/LineLength
  def config
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
            }
          },
          schemas: [
            generic_schemas,
            hlr_v2_schemas
          ].reduce(&:merge)
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

  private

  def generic_schemas
    {
      'nonBlankString': {
        'type': 'string',
        'pattern': '[^ \\f\\n\\r\\t\\v\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\ufeff]',
        '$comment': "The pattern used ensures that a string has at least one non-whitespace character. The pattern comes from JavaScript's \\s character class. \"\\s Matches a single white space character, including space, tab, form feed, line feed, and other Unicode spaces. Equivalent to [ \\f\\n\\r\\t\\v\\u00a0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000\\ufeff].\": https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions/Character_Classes  We are using simple character classes at JSON Schema's recommendation: https://tools.ietf.org/html/draft-handrews-json-schema-validation-01#section-4.3"
      },
      'date': {
        'type': 'string',
        'pattern': '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
      },
      'contestableIssues': {
        'type': 'object',
        'properties': {
          'data': {
            'type': 'array',
            'items': JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'schemas', 'contestable_issue.json')))
          }
        }
      }
    }
  end

  def hlr_v2_schemas
    {
      'hlrCreatePhone': {
        'type': 'object',
        'properties': {
          'countryCode': {
            'type': 'string',
            'pattern': '^[0-9]+$',
            'minLength': 1,
            'maxLength': 3
          },
          'areaCode': {
            'type': 'string',
            'pattern': '^[2-9][0-9]{2}$',
            'minLength': 1,
            'maxLength': 4
          },
          'phoneNumber': {
            'type': 'string',
            'pattern': '^[0-9]{1,14}$',
            'minLength': 1,
            'maxLength': 14
          },
          'phoneNumberExt': {
            'type': 'string',
            'pattern': '^[a-zA-Z0-9]{1,10}$',
            'minLength': 1,
            'maxLength': 10
          }
        },
        'required': %w[
          areaCode
          phoneNumber
        ]
      },
      'hlrCreate': {
        'type': 'object',
        'properties': {
          'data': {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'enum': [
                  'higherLevelReview'
                ]
              },
              'attributes': {
                'description': 'If informal conference requested (`informalConference: true`), contact (`informalConferenceContact`) and time (`informalConferenceTime`) must be specified.',
                'type': 'object',
                'additionalProperties': false,
                'properties': {
                  'informalConference': {
                    'type': 'boolean'
                  },
                  'benefitType': {
                    'type': 'string',
                    'enum': [
                      'compensation'
                    ]
                  },
                  'veteran': {
                    'type': 'object',
                    'properties': {
                      'homeless': {
                        'type': 'boolean'
                      },
                      'address': {
                        'type': 'object',
                        'properties': {
                          'addressLine1': {
                            'type': 'string',
                            'maxLength': 60
                          },
                          'addressLine2': {
                            'type': 'string',
                            'maxLength': 30
                          },
                          'addressLine3': {
                            'type': 'string',
                            'maxLength': 10
                          },
                          'city': {
                            'type': 'string',
                            'maxLength': 60
                          },
                          'stateCode': JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'state_codes.json'))),
                          'countryCodeISO2': {
                            'type': 'string',
                            'pattern': '^[A-Z]{2}$'
                          },
                          'zipCode5': {
                            'type': 'string',
                            'description': '5-digit zipcode. Use "00000" if Veteran is outside the United States',
                            'pattern': '^[0-9]{5}$'
                          },
                          'internationalPostalCode': { 'type': 'string', 'maxLength': 16 }
                        },
                        'additionalProperties': false
                      },
                      'phone': {
                        '$ref': '#/components/schemas/hlrCreatePhone'
                      },
                      'email': {
                        'type': 'string',
                        'format': 'email',
                        'minLength': 6,
                        'maxLength': 255
                      },
                      'timezone': JSON.parse(File.read(AppealsApi::Engine.root.join('spec', 'support', 'time_zones.json')))
                    },
                    'additionalProperties': false,
                    'required': [
                      'homeless'
                    ]
                  },
                  'informalConferenceContact': {
                    'type': 'string',
                    'enum': %w[
                      veteran
                      representative
                    ]
                  },
                  'informalConferenceTime': {
                    'type': 'string',
                    'enum': [
                      '800-1200 ET',
                      '1200-1630 ET'
                    ]
                  },
                  'informalConferenceRep': {
                    'type': 'object',
                    'description': 'The Representative information listed MUST match the current Power of Attorney for the Veteran.  Any changes to the Power of Attorney must be submitted via a VA 21-22 form separately.',
                    'properties': {
                      'firstName': {
                        'type': 'string',
                        'maxLength': 30
                      },
                      'lastName': {
                        'type': 'string',
                        'maxLength': 40
                      },
                      'phone': {
                        '$ref': '#/components/schemas/hlrCreatePhone'
                      },
                      'email': {
                        'type': 'string',
                        'format': 'email',
                        'minLength': 6,
                        'maxLength': 255
                      }
                    },
                    'additionalProperties': false,
                    'required': %w[
                      firstName
                      lastName
                      phone
                    ]
                  },
                  'socOptIn': {
                    'type': 'boolean'
                  }
                },
                'required': %w[
                  informalConference
                  benefitType
                  veteran
                  socOptIn
                ],
                'if': {
                  'properties': {
                    'informalConference': {
                      'const': true
                    }
                  }
                },
                'then': {
                  'required': %w[
                    informalConferenceContact
                    informalConferenceTime
                  ]
                }
              }
            },
            'additionalProperties': false,
            'required': %w[
              type
              attributes
            ]
          },
          'included': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'type': {
                  'type': 'string',
                  'enum': [
                    'contestableIssue'
                  ]
                },
                'attributes': {
                  'type': 'object',
                  'properties': {
                    'issue': {
                      'allOf': [
                        {
                          '$ref': '#/components/schemas/nonBlankString'
                        },
                        {
                          'maxLength': 140
                        }
                      ]
                    },
                    'decisionDate': {
                      '$ref': '#/components/schemas/date'
                    },
                    'decisionIssueId': {
                      'type': 'integer'
                    },
                    'ratingIssueReferenceId': {
                      'type': 'string'
                    },
                    'ratingDecisionReferenceId': {
                      'type': 'string'
                    },
                    'socDate': {
                      '$ref': '#/components/schemas/date'
                    }
                  },
                  'additionalProperties': false,
                  'required': %w[
                    issue
                    decisionDate
                  ]
                }
              },
              'additionalProperties': false,
              'required': %w[
                type
                attributes
              ]
            },
            'minItems': 1,
            'uniqueItems': true
          }
        },
        'additionalProperties': false,
        'required': %w[
          data
          included
        ]
      }
    }
  end
  # rubocop:enable Metrics/MethodLength, Layout/LineLength
end
