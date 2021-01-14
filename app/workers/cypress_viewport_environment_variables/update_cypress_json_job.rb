# frozen_string_literal: true

require_relative './google_analytics_reports'
require_relative './viewport_collection'

module CypressViewportEnvironmentVariables
  class UpdateCypressJsonJob
    include Sidekiq::Worker

    START_DATE = Date.today.prev_month.beginning_of_month
    END_DATE = Date.today.prev_month.end_of_month

    def perform
      reports = CypressViewportEnvironmentVariables::
                  GoogleAnalyticsReports.new(START_DATE, END_DATE)
      viewport_collection = CypressViewportEnvironmentVariables::
                              ViewportCollection.new(start_date: START_DATE,
                                                     end_date: END_DATE,
                                                     user_report: reports.user_report,
                                                     viewport_report: reports.viewport_report)

      # get cypress file
      # edit file
      # save file
      # create new git branch
      # commit file
      # submit pr
    end
  end
end