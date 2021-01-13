# frozen_string_literal: true

require_relative './google_analytics_viewport_report'

module CypressViewportEnvironmentVariables
  class UpdateCypressJsonJob
    include Sidekiq::Worker

    START_DATE = Date.today.prev_month.beginning_of_month
    END_DATE = Date.today.prev_month.end_of_month

    def perform
      report = CypressViewportEnvironmentVariables::
                 GoogleAnalyticsViewportReport.new(START_DATE, END_DATE).get
    end
  end
end