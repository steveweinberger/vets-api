# frozen_string_literal: true

require 'caseflow/service'
require 'common/exceptions'
require 'appeals_api/form_schemas'

module AppealsApi::V2
  module DecisionReviews
    class ContestableIssuesController < AppealsApi::ApplicationController
      def index
        issues_response = AppealsApi::ContestableIssuesRetrieval.new(params).start!
        render issues_response, status: issues_response[:status]
      end
    end
  end
end
