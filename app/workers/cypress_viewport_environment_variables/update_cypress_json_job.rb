# frozen_string_literal: true

require_relative './google_analytics_reports'
require_relative './viewport_collection'

module CypressViewportUpdater
  class UpdateCypressJsonJob
    include Sidekiq::Worker

    START_DATE = Date.today.prev_month.beginning_of_month
    END_DATE = Date.today.prev_month.end_of_month

    def perform
      reports = CypressViewportUpdater::
                  GoogleAnalyticsReports.new(start_date: START_DATE,
                                             end_date: END_DATE)
      viewport_collection = CypressViewportUpdater::
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