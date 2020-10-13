# frozen_string_literal: true

require 'common/client/base'
require 'common/client/concerns/monitoring'
require 'debts/financial_status_report/configuration'

module Debts
  class FinancialStatusReportService < Common::Client::Base
    include Common::Client::Concerns::Monitoring

    configuration Debts::Configuration

    STATSD_KEY_PREFIX = 'api.debts'

    def submit
    end
  end
end
