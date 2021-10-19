# frozen_string_literal: true

require 'appeals_api/form_schemas'

module AppealsApi
  class ContestableIssuesRetrieval

    VALID_DECISION_REVIEW_TYPES = %w[higher_level_reviews notice_of_disagreements supplemental_claims].freeze

    def initialize(decision_review_type:, benefit_type: nil, raw_headers:)
      @decision_review_type = decision_review_type
      @benefit_type = benefit_type
      @raw_headers = raw_headers
    end

    def start!
      return @header_errors unless headers_valid?
      return invalid_decision_review_type_error if invalid_decision_review_type?

      filter_response(call_caseflow)
    end

    private

    def filter_response(caseflow_response)
      return caseflow_response unless caseflow_response[:status] == 200
    end

    def call_caseflow
      Caseflow::Service.new.get_contestable_issues(
        headers: request_headers,
        benefit_type: benefit_type,
        decision_review_type: caseflow_decision_review_type
      )
    rescue Common::Exceptions::BackendServiceException => backend_service_exception
      errored_caseflow_response(backend_service_exception)
    end

    private

    attr_reader :decision_review_type, :benefit_type, :header_errors

    def caseflow_decision_review_type
      return 'appeals' if decision_review_type == 'notice_of_disagreements'
      decision_review_type
    end

    def request_headers
      @request_headers ||=
        required_contestable_issues_headers.index_with { |key| @raw_headers[key]}.compact
    end

    def headers_valid?
      begin
        AppealsApi::FormSchemas.new(
          Common::Exceptions::DetailedSchemaErrors,
          schema_version: 'v2'
        ).validate!('CONTESTABLE_ISSUES_HEADERS', request_headers)
      rescue => e
        errors = e.errors.map(&:to_h).map(&:compact)
        @header_errors = error_response(errors)
        false
      end
    end

    def required_contestable_issues_headers
      JSON.parse(
        File.read(
          AppealsApi::Engine.root.join('config/schemas/v2/contestable_issues_headers.json')
        )
      )['definitions']['contestableIssuesIndexParameters']['properties'].keys
    end

    def invalid_decision_review_type?
      !decision_review_type.in?(VALID_DECISION_REVIEW_TYPES)
    end

    def invalid_decision_review_type_error
      error_response(
        [
          {
            title: 'Unprocessable Entity',
            code: 'unprocessable_entity',
            detail: "decision_review_type must be one of: #{VALID_DECISION_REVIEW_TYPES.join(', ')}",
            status: '422'
          }
        ]
      )
    end

    def errored_caseflow_response(backend_service_exception)
      return error_response(unusable_response_errors) unless response_is_usable?(backend_service_exception)

      error_response(backend_service_exception)
    end

    def response_is_usable?(response)
      binding.pry
      response.try(:status) && response.try(:body).is_a?(Hash)
    end

    def unusable_response_errors
      [
        {
          title: 'Bad Gateway',
          code: 'bad_gateway',
          detail: 'Received an unusable response from Caseflow.',
          status: 502
        }
      ]
    end

    def error_response(errors)
      {
        errors: errors,
        status: errors.first[:status]
      }
    end
  end
end
