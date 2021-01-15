# frozen_string_literal: true

require_relative './google_analytics_reports'
require_relative './viewport_collection'

module CypressViewportUpdater
  class UpdateCypressViewportsJob
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


      Octokit::Client.new(client_id: 'Iv1.6ab544c8f04d383c', client_secret: '378292d09573f3ed2f9d7d977b6d47f20fe7e337')
      
      # TO-DO
      # two files to update:
      # cypress.json
      # viewportPreset.js

      # implement open, update and save for each file locally (no access to github api yet):
      # open cypress.json
      # update cypress.json
      # save cypress.json

      # open viewportPreset.js
      # update viewportPreset.js
      # save viewportPreset.js

      # GITHUB API
      # get cypress.json
      # get viewportPreset.js
      # update files (see above)

      # create new git branch
      # commit cypress.json
      # commit viewportPreset.js
      # submit pr
    end
  end
end