# frozen_string_literal: true

module FinancialStatusReport
  class Response
    def initialize(res)
      @res = res
    end

    private

    def validate_response_against_schema
      schema_path = Rails.root.join('lib', 'debts', 'schemas', 'submit.json').to_s
      JSON::Validator.validate!(schema_path, @res, strict: false)
    end
  end
end
