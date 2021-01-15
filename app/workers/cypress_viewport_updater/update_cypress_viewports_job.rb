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
      file = File.read('app/workers/cypress_viewport_updater/old_files/cypress.json')
      hash = JSON.parse(file)
      hash['env']['vaTopMobileViewports'] = viewport_collection.viewports[:mobile]
      hash['env']['vaTopTabletViewports'] = viewport_collection.viewports[:tablet]
      hash['env']['vaTopDesktopViewports'] = viewport_collection.viewports[:desktop]

      directory_name = 'app/workers/cypress_viewport_updater/updated_files'
      Dir.mkdir(directory_name) unless Dir.exist?(directory_name)

      # JSON.pretty_generate() does not convert Ruby objects to json
      # You must first convert the hash to json to convert Ruby objects to json
      # Convert that json back to a hash
      # Then call JSON.pretty_generate() with the new hash
      json = hash.to_json
      new_hash = JSON.parse(json)
      File.write('app/workers/cypress_viewport_updater/updated_files/cypress.json',
                    JSON.pretty_generate(new_hash))
    end
  end
end