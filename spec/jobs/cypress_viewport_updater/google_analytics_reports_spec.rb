# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::GoogleAnalyticsReports do
  context 'POST request to request reports' do
    before do
      VCR.use_cassette('cypress_viewport_updater/gets_reports_from_google_analytics') do |cassette|
        request = cassette.serializable_hash['http_interactions'][1]['request']
        body = JSON.parse(request['body']['string']).to_h
        @report_requests = body['reportRequests']
      end
    end

    it 'each request has the correct date range' do
      @report_requests.each do |report_request|
        date_ranges = report_request['dateRanges'].first
        expect(date_ranges['startDate']).to eq('2020-12-01')
        expect(date_ranges['endDate']).to eq('2020-12-31')
      end
    end

    it 'request for device category and screen resolutions report to be sorted by number of users descending' do
      order_bys = @report_requests.second['orderBys'].first
      expect(order_bys['fieldName']).to eq('ga:users')
      expect(order_bys['sortOrder']).to eq('DESCENDING')
    end
  end

  context 'POST response to request reports' do
    before do
      VCR.use_cassette('cypress_viewport_updater/gets_reports_from_google_analytics') do |cassette|
        @response = cassette.serializable_hash['http_interactions'][1]['response']
      end
    end

    it 'returns 200 OK response' do
      status = @response['status']
      expect(status['code']).to eq(200)
      expect(status['message']).to eq('OK')
    end
  end

  context 'user report' do
    before do
      VCR.use_cassette('cypress_viewport_updater/gets_reports_from_google_analytics') do
        @client = CypressViewportUpdater::GoogleAnalyticsReports.new
      end
    end

    it 'metric name is ga:users' do
      metric_name = @client.user_report.column_header.metric_header.metric_header_entries.first.name
      expect(metric_name).to eq('ga:users')
    end

    it 'has a row count of 1' do
      row_count = @client.user_report.data.row_count
      expect(row_count).to eq(1)
    end

    it 'has total number of users' do
      total_users = @client.user_report.data.rows.first.metrics.first.values.first
      expect(total_users).to eq('14356199')
    end
  end

  context 'viewport report' do
    before do
      VCR.use_cassette('cypress_viewport_updater/gets_reports_from_google_analytics') do
        @client = CypressViewportUpdater::GoogleAnalyticsReports.new
      end
    end

    it 'metric name is ga:users' do
      metric_name = @client.viewport_report.column_header.metric_header.metric_header_entries.first.name
      expect(metric_name).to eq('ga:users')
    end

    it 'primary dimension is ga:deviceCategory' do
      primary_dimension = @client.viewport_report.column_header.dimensions.first
      expect(primary_dimension).to eq('ga:deviceCategory')
    end

    it 'secondary dimension is ga:screenResolution' do
      secondary_dimension = @client.viewport_report.column_header.dimensions.second
      expect(secondary_dimension).to eq('ga:screenResolution')
    end

    it 'has 100 results' do
      results_total = @client.viewport_report.data.rows.count
      expect(results_total).to eq(100)
    end

    it 'includes mobile devices' do
      includes_mobile = @client.viewport_report.data.rows.any? do |row|
        row.dimensions.first == 'mobile'
      end

      expect(includes_mobile).to be true
    end

    it 'includes tablet devices' do
      includes_tablet = @client.viewport_report.data.rows.any? do |row|
        row.dimensions.first == 'tablet'
      end

      expect(includes_tablet).to be true
    end

    it 'includes desktop devices' do
      includes_desktop = @client.viewport_report.data.rows.any? do |row|
        row.dimensions.first == 'desktop'
      end

      expect(includes_desktop).to be true
    end

    it 'includes screen resolutions' do
      includes_screen_resolutions = @client.viewport_report.data.rows.any? do |row|
        /[\d]+x[\d]+/.match(row.dimensions.second)
      end

      expect(includes_screen_resolutions).to be true
    end
  end
end
