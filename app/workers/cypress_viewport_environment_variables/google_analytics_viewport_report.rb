require 'google/apis/analyticsreporting_v4'

module CypressViewportEnvironmentVariables
  class GoogleAnalyticsViewportReport
    include Google::Apis::AnalyticsreportingV4
    include Google::Auth

    VIEW_ID = "176188361"
    SCOPE = "https://www.googleapis.com/auth/analytics.readonly"
    JSON_CREDENTIALS = File.open('./app/workers/cypress_viewport_environment_variables/analytics-api-key.json')

    attr_reader :analytics, :get_report_request, :report_request,
                :start_date, :end_date

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
      @analytics = AnalyticsReportingService.new
      analytics.authorization = ServiceAccountCredentials.make_creds(
                                  json_key_io: JSON_CREDENTIALS,
                                  scope: SCOPE)
      @get_report_request = GetReportsRequest.new
      @report_request = ReportRequest.new
    end

    def get
      make_report
    end

    private

    def make_report
      add_view_id
      add_metric
      add_date_range
      add_dimensions
      add_sort
      add_limit
      get_report_request.report_requests = [report_request]
      analytics.batch_get_reports(get_report_request).reports.first
    end

    def add_view_id
      report_request.view_id = VIEW_ID
    end

    def add_metric
      metric = Metric.new
      metric.expression = "ga:users"
      report_request.metrics = [metric]
    end

    def add_date_range
      range = DateRange.new
      range.start_date = start_date
      range.end_date = end_date
      report_request.date_ranges = [range]
    end

    def add_dimensions
      primary_dimension = Dimension.new(name: 'ga:deviceCategory')
      secondary_dimension = Dimension.new(name: 'ga:screenResolution')
      report_request.dimensions = [primary_dimension, secondary_dimension]
    end

    def add_sort
      report_request.order_bys = [{ field_name: "ga:users", sort_order: "DESCENDING" }]
    end

    def add_limit
      report_request.page_size = 500
    end
  end
end