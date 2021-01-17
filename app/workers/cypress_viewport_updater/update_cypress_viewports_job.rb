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
      create_updated_cypress_json_file(viewport_collection)
      # update_cypress_json_file(viewport_collection)
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

    private

    def create_updated_cypress_json_file(viewport_collection)
      old_file_path = 'app/workers/cypress_viewport_updater/old_files/cypress.json'
      new_file_path = 'app/workers/cypress_viewport_updater/updated_files/cypress.json'
      hash = JSON.parse(File.read(old_file_path))
      update_viewports(hash: hash, collection: viewport_collection)
      File.delete(new_file_path) if File.exist?(new_file_path)
      File.write(new_file_path, JSON.pretty_generate(JSON.parse(hash.to_json)))
    end

    def update_viewports(hash:, collection:)
      hash['env']['vaTopMobileViewports'] = collection.viewports[:mobile]
      hash['env']['vaTopTabletViewports'] = collection.viewports[:tablet]
      hash['env']['vaTopDesktopViewports'] = collection.viewports[:desktop]
    end
  end
end