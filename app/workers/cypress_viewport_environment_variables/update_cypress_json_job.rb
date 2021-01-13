# frozen_string_literal: true

require_relative './google_analytics_report'
require_relative './viewport_collection'

module CypressViewportEnvironmentVariables
  class UpdateCypressJsonJob
    include Sidekiq::Worker

    START_DATE = Date.today.prev_month.beginning_of_month
    END_DATE = Date.today.prev_month.end_of_month

    def perform
      report = CypressViewportEnvironmentVariables::
                 GoogleAnalyticsReport.new(START_DATE, END_DATE)
      user_report = report.user_report
      viewport_report = report.viewport_report

      # create viewport collections
      # get cypress file
      # edit file
      # save file
      # create new git branch
      # commit file
      # submit pr
    end
  end
end