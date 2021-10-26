class VBADocuments::RswagConfig
  def config
    {
      'modules/vba_documents/app/swagger/vba_documents/v2/swagger.json' => {
        # ^ This path points to wherever you would like Rswag to save the generated swagger json file.
        openapi: '3.0.1',
        info: {
          title: 'VBA Documents',
          version: 'v2',
          termsOfService: 'https://developer.va.gov/terms-of-service',
          description: File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents',
                                                                'v2', 'description.md'))
          # ^ You could have the description inline, but saving it as a standalone file makes it easier to edit/manage
        },
        tags: [
          {
            name: 'VBA Documents',
            description: ''
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
            'ErrorModel': error_model('#/components/schemas'),
            'DocumentUploadPath': document_upload_path('#/components/schemas'),
            'PdfUploadAttributes': pdf_upload_attributes('#/components/schemas'),
            'DocumentUploadStatus': document_upload_status('#/components/schemas'),
            'DocumentUploadFailure': document_upload_failure('#/components/schemas'),
            'DocumentUploadMetadata': document_upload_metadata('#/components/schemas', 2),
            'PdfDimensionAttributes': pdf_dimension_attributes('#/components/schemas'),
            'DocumentUploadAttributes': document_upload_attributes('#/components/schemas'),
            'DocumentUploadSubmission': document_upload_submission('#/components/schemas'),
            'DocumentUploadStatusReport': document_upload_status_report('#/components/schemas'),
            'DocumentUploadStatusGuidList': document_upload_status_guid_list('#/components/schemas'),
            'DocumentUploadStatusAttributes': document_upload_status_attributes('#/components/schemas'),
            'DocumentUploadSubmissionAttributes': document_upload_submission_attributes('#/components/schemas')
          }
        },
        paths: {},
        basePath: '/services/vba_documents/v2',
        # ^ basePath is used in building up the url that Rswag will use in testing
        servers: [
          # ^ Used in creating the 'Environment' drop-down for generating example curl commands
          {
            url: 'https://sandbox-api.va.gov/services/vba_documents/{version}',
            description: 'Sandbox',
            variables: {
              version: {
                default: 'v2'
              }
            }
          },
          {
            url: 'https://api.va.gov/services/vba_documents/{version}',
            description: 'Production',
            variables: {
              version: {
                default: 'v2'
              }
            }
          }
        ]
      },
      'modules/vba_documents/app/swagger/vba_documents/v1/swagger.json' => {
        # ^ This path points to wherever you would like Rswag to save the generated swagger json file.
        openapi: '3.0.1',
        info: {
          title: 'VBA Documents',
          version: 'v1',
          termsOfService: 'https://developer.va.gov/terms-of-service',
          description: File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents',
          'v1', 'description.md'))
        # ^ You could have the description inline, but saving it as a standalone file makes it easier to edit/manage
        },
        tags: [
          {
            name: 'VBA Documents',
            description: ''
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
            'ErrorModel': error_model('#/components/schemas'),
            'DocumentUploadPath': document_upload_path('#/components/schemas'),
            'PdfUploadAttributes': pdf_upload_attributes('#/components/schemas'),
            'DocumentUploadStatus': document_upload_status('#/components/schemas'),
            'DocumentUploadFailure': document_upload_failure('#/components/schemas'),
            'DocumentUploadMetadata': document_upload_metadata('#/components/schemas', 1),
            'PdfDimensionAttributes': pdf_dimension_attributes('#/components/schemas'),
            'DocumentUploadAttributes': document_upload_attributes('#/components/schemas'),
            'DocumentUploadSubmission': document_upload_submission('#/components/schemas'),
            'DocumentUploadStatusReport': document_upload_status_report('#/components/schemas'),
            'DocumentUploadStatusGuidList': document_upload_status_guid_list('#/components/schemas'),
            'DocumentUploadStatusAttributes': document_upload_status_attributes('#/components/schemas'),
            'DocumentUploadSubmissionAttributes': document_upload_submission_attributes('#/components/schemas')
          }
        },
        paths: {},
        basePath: '/services/vba_documents/v1',
        # ^ basePath is used in building up the url that Rswag will use in testing
        servers: [
          # ^ Used in creating the 'Environment' drop-down for generating example curl commands
          {
            url: 'https://sandbox-api.va.gov/services/vba_documents/{version}',
            description: 'Sandbox',
            variables: {
              version: {
                default: 'v1'
              }
            }
          },
          {
            url: 'https://api.va.gov/services/vba_documents/{version}',
            description: 'Production',
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

  def error_model(ref_root)
    {
      "type": 'object',
      "description": 'Errors with some details for the given request',
      "required": %w[detail status],
      "properties": {
        "detail": {
          "type": 'string',
          "minLength": 0,
          "maxLength": 1000,
          "example": 'DOC104 - Upload rejected by upstream system. Processing failed and upload must be resubmitted',
          "description": 'A more detailed message about why the error occured'
        },
        "status": {
          "type": 'integer',
          "format": 'int32',
          "minimum": 100,
          "maximum": 599,
          "example": 422,
          "description": 'Standard HTTP Status returned with Error'
        }
      }
    }
  end

  def document_upload_path(ref_root)
    {
      "type": 'object',
      "description": 'Status record for a previously initiated document submission.',
      "required": %w[id type attributes],
      "properties": {
        "id": {
          "type": 'string',
          "format": 'uuid',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "minLength": 36,
          "maxLength": 36,
          "description": 'JSON API identifier'
        },
        "type": {
          "type": 'string',
          "example": 'document_upload',
          "minLength": 15,
          "maxLength": 15,
          "description": 'JSON API type specification'
        },
        "attributes": {
          '$ref': "#{ref_root}/DocumentUploadAttributes"
        }
      }
    }
  end

  def pdf_upload_attributes(ref_root)
    {
      "type": 'object',
      "required": %w[content total_pages total_documents],
      "properties": {
        "content": {
          "type": 'object',
          "properties": {
            "dimensions": {
              '$ref': "#{ref_root}/PdfDimensionAttributes"
            },
            "page_count": {
              "type": 'integer',
              "example": 1,
              "minimum": 0,
              "maximum": 32767,
              "description": 'The total number of pages solely in this PDF document'
            },
            "attachments": {
              "type": 'array',
              "minItems": 0,
              "maxItems": 32767,
              "items": {
                "type": 'object',
                "properties": {
                  "dimensions": {
                    '$ref': "#{ref_root}/PdfDimensionAttributes"
                  },
                  "page_count": {
                    "type": 'integer',
                    "example": 2,
                    "minimum": 0,
                    "maximum": 32767,
                    "description": 'The number of pages in this attachment'
                  }
                }
              }
            }
          }
        },
        "total_pages": {
          "type": 'integer',
          "example": 3,
          "minimum": 0,
          "maximum": 32767,
          "description": 'The total number of pages contained in this upload'
        },
        "total_documents": {
          "type": 'integer',
          "example": 2,
          "minimum": 0,
          "maximum": 32767,
          "description": 'The total number of documents contained in this upload'
        }
      }
    }
  end

  def document_upload_status(ref_root)
    {
      "type": 'object',
      "description": 'Status record for a previously initiated document submission',
      "required": %w[id type attributes],
      "properties": {
        "id": {
          "type": 'string',
          "format": 'uuid',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "minLength": 36,
          "maxLength": 36,
          "description": 'JSON API identifier'
        },
        "type": {
          "type": 'string',
          "example": "document_upload",
          "minLength": 15,
          "maxLength": 15,
          "description": 'JSON API type specification'
        },
        "attributes": {
          '$ref': "#{ref_root}/DocumentUploadStatusAttributes"
        }
      }
    }
  end

  def document_upload_failure(ref_root)
    {
      "type": 'object',
      "description": 'Document upload failed',
      "properties": {
        "Code": {
          "type": 'string',
          "example": 'SignatureDoesNotMatch',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Error code'
        },
        "Message": {
          "type": 'string',
          "example": 'The request signature we calculated does not match the signature you provided. Check your key and signing method.',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Error detail'
        }
      }
    }
  end

  def document_upload_metadata(ref_root, version=1)
    businessLineFirstLine = 'Optional parameter (can be missing or empty). The values are:\n'
    requiredList = %w[source zipCode fileNumber veteranLastName veteranFirstName]
    if version > 1
      businessLineFirstLine = 'Required parameter. The values are:\n'
      requiredList = %w[source zipCode fileNumber businessLine veteranLastName veteranFirstName]
    end

    {
      "type": 'object',
      "description": 'Identifying properties about the document payload being submitted',
      "required": requiredList,
      "properties": {
        "source": {
          "type": 'string',
          "example": 'MyVSO',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'System, installation, or entity submitting the document'
        },
        "docType": {
          "type": 'string',
          "example": '21-22',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'VBA form number of the document'
        },
        "zipCode": {
          "type": 'string',
          "example": '20571',
          "pattern": '^[0-9]{5}|[0-9]{5}-[0-9]{4}$',
          "minLength": 5,
          "maxLength": 10,
          "description": "Veteran zip code. Either five digits (XXXXX) or five digits then four digits separated by a hyphen (XXXXX-XXXX). Use '00000' for Veterans with non-US addresses."
        },
        "fileNumber": {
          "type": 'string',
          "example": '999887777',
          "pattern": '^[0-9]{8,9}$',
          "minLength": 8,
          "maxLength": 9,
          "description": 'The Veteran\'s file number is exactly 9 digits with no alpha characters, hyphens, spaces or punctuation. In most cases, this is the Veteran\'s SSN but may also be an 8 digit BIRL number. If no file number has been established or if it is unknown, the application should use the Veteran\'s SSN and the file number will be associated with the submission later in the process. Incorrect file numbers can cause delays.'
        },
        "businessLine": {
          "type": 'string',
          "example": 'CMP',
          "minLength": 0,
          "maxLength": 1000,
          "enum": %w[CMP PMC INS EDU VRE BVA FID OTH],
          "description":
            <<~DESCRIPTION
              #{businessLineFirstLine}
              CMP - Compensation requests such as those related to disability, unemployment, and pandemic claims<br><br>
              PMC - Pension requests including survivorâ€™s pension<br><br>
              INS - Insurance such as life insurance, disability insurance, and other health insurance<br><br>
              EDU - Education benefits, programs, and affiliations<br><br>
              VRE - Veteran Readiness & Employment such as employment questionnaires, employment discrimination, employment verification<br><br>
              BVA - Board of Veteran Appeals<br><br>
              FID - Fiduciary / financial appointee, including family member benefits<br><br>
              OTH - Other (this value if used, will be treated as CMP)<br>
          DESCRIPTION
        },
        "veteranLastName": {
          "type": 'string',
          "example": 'Doe-Smith',
          "pattern": '^[a-zA-Z\-\/\s]{1,50}$',
          "minLength": 1,
          "maxLength": 50,
          "description": 'Veteran last name. Cannot be missing or empty or longer than 50 characters. Only upper/lower case letters, hyphens(-), spaces and forward-slash(/) allowed.'
        },
        "veteranFirstName": {
          "type": 'string',
          "example": 'Jane',
          "minLength": 1,
          "maxLength": 50,
          "pattern": '^[a-zA-Z\-\/\s]{1,50}$',
          "description": 'Veteran first name. Cannot be missing or empty or longer than 50 characters. Only upper/lower case letters, hyphens(-), spaces and forward-slash(/) allowed.'
        }
      }
    }
  end

  def pdf_dimension_attributes(ref_root)
    {
      "type": 'object',
      "required": %w[width height oversized_pdf],
      "properties": {
        "width": {
          "type": 'number',
          "example": 8.5,
          "description": 'The document width'
        },
        "height": {
          "type": 'number',
          "example": 11.0,
          "description": 'The document height'
        },
        "oversized_pdf": {
          "type": 'boolean',
          "example": false,
          "description": 'Indicates if this is an oversized PDF (greater than 21x21)'
        }
      }
    }
  end

  def document_upload_attributes(ref_root)
    {
      "type": 'object',
      "required": %w[guid status],
      "properties": {
        "code": {
          "type": %w[string null],
          "pattern": '^DOC[0-9]{3}$',
          "minLength": 6,
          "maxLength": 6,
          "description": File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents',
                                                                  'document_upload', 'status_code_description.md'))
        },
        "status": {
          "type": 'string',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Document upload status.',
          "enum": %w[pending uploaded received processing success vbms error]
        },
        "guid": {
          "type": 'string',
          "format": 'uuid',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "minLength": 36,
          "maxLength": 36,
          "description": 'The document upload identifier'
        },
        "detail": {
          "type": 'string',
          "description": 'Human readable error detail. Only present if status = "error"',
          "minLength": 0,
          "maxLength": 1000
        },
        "location": {
          "type": 'string',
          "format": 'uri',
          "example": 'https://sandbox-api.va.gov/services_user_content/vba_documents/{idpath}',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Location to which to PUT document Payload'
        },
        "updated_at": {
          "type": 'string',
          "format": 'date-time',
          "example": '2018-07-30T17:31:15.958Z',
          "minLength": 24,
          "maxLenght": 24,
          "pattern": '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z$',
          "description": 'The last time the submission was updated'
        },
        "uploaded_pdf": {
          "type": %w[object null],
          "description": "Only populated after submission starts processing",
          "properties": {
            "description": {
              "type": "string",
              "minLength": 0,
              "maxLength": 1000
            }
          }
        }
      }
    }
  end

  def document_upload_submission(ref_root)
    {
      "type": 'object',
      "description": 'Record of requested document submission. Includes the location to which the document payload is to be uploaded',
      "required": %w[id type attributes],
      "properties": {
        "id": {
          "type": 'string',
          "format": 'uuid',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "minLength": 36,
          "maxLength": 36,
          "description": 'JSON API Identifier'
        },
        "type": {
          "type": 'string',
          "example": "document_upload",
          "minLength": 15,
          "maxLength": 15,
          "description": 'JSON API type specification'
        },
        "attributes": {
          '$ref': "#{ref_root}/DocumentUploadSubmissionAttributes"
        }
      }
    }
  end

  def document_upload_status_report(ref_root)
    {
      "type": 'array',
      "minItems": 0,
      "maxItems": 32767,
      "items": {
        '$ref': "#{ref_root}/DocumentUploadStatus"
      }
    }
  end

  def document_upload_status_guid_list(ref_root)
    {
      "type": 'object',
      "required": %w[ids],
      "properties": {
        "ids": {
          "type": 'array',
          "minItems": 1,
          "maxItems": 1000,
          "description": 'List of IDs for previous document upload submissions',
          "items": {
            "type": 'string',
            "format": 'uuid',
            "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
            "minLength": 36,
            "maxLength": 36,
            "example": '6d8433c1-cd55-4c24-affd-f592287a7572'
          }
        }
      }
    }
  end

  def document_upload_status_attributes(ref_root)
    {
      "type": 'object',
      "required": %w[guid status],
      "properties": {
        "code": {
          "type": 'string',
          "pattern": '^DOC[0-9]{3}$',
          "minLength": 6,
          "maxLength": 6,
          "description": File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents',
                                                                  'document_upload', 'status_code_description.md'))
        },
        "status": {
          "type": 'string',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Document upload status.',
          "enum": %w[pending uploaded received processing success vbms error]
        },
        "guid": {
          "type": 'string',
          "format": 'uuid',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "minLength": 36,
          "maxLength": 36,
          "description": 'The document upload identifier'
        },
        "detail": {
          "type": 'string',
          "description": 'Human readable error detail. Only present if status = "error"',
          "minLength": 0,
          "maxLength": 1000
        },
        "updated_at": {
          "type": 'string',
          "format": 'date-time',
          "example": '2018-07-30T17:31:15.958Z',
          "pattern": '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z$',
          "minLength": 24,
          "maxLength": 24,
          "description": 'The last time the submission was updated'
        },
        "uploaded_pdf": {
          '$ref': "#{ref_root}/PdfUploadAttributes"
        }
      }
    }
  end

  def document_upload_submission_attributes(ref_root)
    {
      "type": 'object',
      "required": %w[guid status],
      "properties": {
        "code": {
          "type": 'string',
          "pattern": '^DOC[0-9]{3}$',
          "minLength": 6,
          "maxLength": 6,
          "description": File.read(VBADocuments::Engine.root.join('app', 'swagger', 'vba_documents',
                                                                  'document_upload', 'status_code_description.md'))
        },
        "guid": {
          "type": 'string',
          "format": 'uuid',
          "pattern": '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
          "example": '6d8433c1-cd55-4c24-affd-f592287a7572',
          "minLength": 36,
          "maxLength": 36,
          "description": 'The document upload identifier'
        },
        "detail": {
          "type": 'string',
          "description": 'Human readable error detail. Only present if status = "error"',
          "minLength": 0,
          "maxLength": 1000
        },
        "status": {
          "type": 'string',
          "minLength": 0,
          "maxLength": 1000,
          "description": 'Document upload status.',
          "enum": %w[pending uploaded received processing success vbms error]
        },
        "updated_at": {
          "type": 'string',
          "format": 'date-time',
          "example": '2018-07-30T17:31:15.958Z',
          "pattern": '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z$',
          "minLength": 24,
          "maxLength": 24,
          "description": 'The last time the submission was updated'
        },
        "uploaded_pdf": {
          '$ref': "#{ref_root}/PdfUploadAttributes"
        }
      }
    }
  end

  def delete_me
    JSON.parse(File.read(VBADocuments::Engine.root.join('spec', 'support', 'schemas', 'document_upload_path.json')))
  end
end
