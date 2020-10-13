# frozen_string_literal: true

module FinancialStatusReport
  class Configuration < Common::Client::Configuration::REST
    def self.base_request_headers
      super.merge(
        'client_id' => Settings.debts.client_id,
        'client_secret' => Settings.debts.client_secret
      )
    end

    def service_name
      'FinancialStatusReport'
    end

    def base_path
      "#{Settings.debts.url}/api/v1/finacial-status-report/"
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers, request: request_options) do |f|
        f.use :breakers
        f.use Faraday::Response::RaiseError
        f.request :json
        f.response :betamocks if Settings.debts.mock_financial_status_report
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end
  end
end
