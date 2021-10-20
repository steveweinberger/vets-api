# frozen_string_literal: true

require 'appeals_api/form_schemas'

module AppealsApi
  class ContestableIssuesRetrieval
    VALID_DECISION_REVIEW_TYPES = %w[higher_level_reviews notice_of_disagreements supplemental_claims].freeze

    def initialize(decision_review_type:, raw_headers:, benefit_type: nil)
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
      return caseflow_response unless caseflow_response && caseflow_response[:status] == 200
      return caseflow_response unless decision_review_type == 'notice_of_disagreements'
      return caseflow_response if caseflow_response.body['data'].nil?

      caseflow_response.body['data'].reject! do |issue|
        issue['attributes']['ratingIssueSubjectText'].nil?
      end

      caseflow_response.body['data'].sort_by! do |issue|
        Date.strptime(issue['attributes']['approxDecisionDate'], '%Y-%m-%d')
      end

      caseflow_response.body['data'].reverse!

      caseflow_response
    end

    def call_caseflow
      Caseflow::Service.new.get_contestable_issues(
        headers: request_headers,
        benefit_type: benefit_type,
        decision_review_type: caseflow_decision_review_type
      )
    rescue Common::Exceptions::BackendServiceException => e
      errors = map_error_class_to_hash(e.errors)
      error_response(errors)
    end

    attr_reader :decision_review_type, :benefit_type, :header_errors

    def caseflow_decision_review_type
      return 'appeals' if decision_review_type == 'notice_of_disagreements'

      decision_review_type
    end

    def caseflow_benefit_type
      return benefit_type unless decision_review_type == 'supplemental_claims'

      caseflow_benefit_type_mapping[benefit_type]
    end

    def caseflow_benefit_type_mapping
      {
        'compensation' => 'compensation',
        'pensionSurvivorsBenefits' => 'pension',
        'fiduciary' => 'fiduciary',
        'lifeInsurance' => 'insurance',
        'veteransHealthAdministration' => 'vha',
        'veteranReadinessAndEmployment' => 'voc_rehab',
        'loanGuaranty' => 'loan_guaranty',
        'education' => 'education',
        'nationalCemeteryAdministration' => 'nca'
      }
    end

    def request_headers
      @request_headers ||=
        required_contestable_issues_headers.index_with { |key| @raw_headers[key] }.compact
    end

    def headers_valid?
      AppealsApi::FormSchemas.new(
        Common::Exceptions::DetailedSchemaErrors,
        schema_version: 'v2'
      ).validate!('CONTESTABLE_ISSUES_HEADERS', request_headers)
    rescue => e
      errors = map_error_class_to_hash(e.errors)
      @header_errors = error_response(errors)
      false
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
      error_response(map_error_class_to_hash(backend_service_exception.errors))
    end

    def map_error_class_to_hash(errors)
      errors.map(&:to_h).map(&:compact)
    end

    def error_response(errors)
      {
        errors: errors,
        status: errors.first[:status]
      }
    end
  end
end
