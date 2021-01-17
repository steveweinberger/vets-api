require 'google/apis/analyticsreporting_v4'

module CypressViewportUpdater
  class GoogleAnalyticsReports
    include Google::Apis::AnalyticsreportingV4
    include Google::Auth

    JSON_CREDENTIALS = YAML::load(File.open('config/settings.local.yml'))['google_analytics_service_credentials'].to_json
    SCOPE = "https://www.googleapis.com/auth/analytics.readonly"
    VIEW_ID = "176188361"

    attr_reader :start_date, :end_date, :analytics, :user_report, :viewport_report

    def initialize(start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @analytics = AnalyticsReportingService.new
      analytics.authorization = ServiceAccountCredentials.make_creds(
                                  json_key_io: StringIO.new(JSON_CREDENTIALS),
                                  scope: SCOPE)
      @user_report = nil
      @viewport_report = nil
      create_reports
    end

    private

    attr_writer :user_report, :viewport_report

    def create_reports
      request = GetReportsRequest.new(report_requests: [
                 user_report_request,
                 viewport_report_request])

      response = analytics.batch_get_reports(request)
      self.user_report, self.viewport_report = response.reports[0], response.reports[1]
    end

    def user_report_request
      ReportRequest.new(
        view_id: VIEW_ID,
        date_ranges: [date_range],
        metrics: [metric_user],
      )
    end

    def viewport_report_request
      ReportRequest.new(
        view_id: VIEW_ID,
        date_ranges: [date_range],
        metrics: [metric_user],
        dimensions: [dimension_device_category, dimension_screen_resolution],
        order_bys: [{ field_name: "ga:users", sort_order: "DESCENDING" }],
        page_size: 100,
      )
    end

    def date_range
      DateRange.new(start_date: start_date, end_date: end_date)
    end

    def metric_user
      Metric.new(expression: 'ga:users')
    end

    def dimension_device_category
      Dimension.new(name: 'ga:deviceCategory')
    end

    def dimension_screen_resolution
      Dimension.new(name: 'ga:screenResolution')
    end
  end
end
