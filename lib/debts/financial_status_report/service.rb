# frozen_string_literal: true

require 'common/client/base'
require 'common/client/concerns/monitoring'
require 'debts/financial_status_report/configuration'

module FinancialStatusReport
  class Response
    include Common::Client::Concerns::Monitoring

    configuration FinancialStatusReport::Configuration

    STATSD_KEY_PREFIX = 'api.financial_status_report'

    def submit(request_body)
      with_monitoring_and_error_handling do
        FinancialStatusReport::Response.new(
          perform(:post, 'submit', request_body).body
        )
      end
    end
  end
end
