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
      create_updated_viewport_preset_js_file(viewport_collection)
      # TO-DO
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

    def create_updated_viewport_preset_js_file(viewport_collection)
      old_file_path = 'app/workers/cypress_viewport_updater/old_files/viewportPreset.js'
      new_file = create_new_viewport_preset_js_file

      File.open(old_file_path, 'r').each do |line|
        if /va-top-(mobile|tablet|desktop)-\d+/.match(line)
          if /va-top-(mobile|tablet|desktop)-1/.match(line)
            print_viewport_presets(file: new_file,
                                   line: line,
                                   collection: viewport_collection)
          end
        else
          new_file.print line
        end
      end

      new_file.close
    end

    def create_new_viewport_preset_js_file
      new_file_path = 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js'
      File.delete(new_file_path) if File.exist?(new_file_path)
      File.new(new_file_path, 'w')
    end

    def print_viewport_presets(file:, line:, collection:)
      viewport_type = /(mobile|tablet|desktop)/.match(line)[0]
      viewports = collection.viewports[viewport_type.to_sym]

      viewports.each_with_index do |viewport, i|
        width = viewport.width
        height = viewport.height
        preset = "  'va-top-#{viewport_type}-#{i + 1}': { width: #{width}, height: #{height} },\n"
        file.print preset
      end
    end
  end
end