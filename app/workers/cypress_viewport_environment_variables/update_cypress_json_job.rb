# frozen_string_literal: true

require_relative './google_analytics_viewport_report'
require_relative './viewport_collection'

module CypressViewportEnvironmentVariables
  class UpdateCypressJsonJob
    include Sidekiq::Worker

    START_DATE = Date.today.prev_month.beginning_of_month
    END_DATE = Date.today.prev_month.end_of_month

    def perform
      report = CypressViewportEnvironmentVariables::
                 GoogleAnalyticsViewportReport.new(START_DATE, END_DATE).get
      viewport_collection = ViewportCollection.new(START_DATE, END_DATE, report)
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