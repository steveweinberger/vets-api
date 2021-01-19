# frozen_string_literal: true

require_relative './google_analytics_reports'
require_relative './viewport_collection'

module CypressViewportUpdater
  class UpdateCypressViewportsJob
    include Sidekiq::Worker

    START_DATE = Time.zone.today.prev_month.beginning_of_month
    END_DATE = Time.zone.today.prev_month.end_of_month

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

      # # The following code uses a temporary personal access token from my account
      # # It connects to a forked version of vets-website
      # # It grabs the files I need to update, creates a new feature brach,
      # #   uploads the files to the new branch, and submits a pr
      # # Next step: Refactor the code.

      # data = YAML.safe_load(File.open('config/settings.local.yml'))
      # ACCESS_TOKEN = data['github_cypress_viewport_updater_bot']['access_token']
      # client = Octokit::Client.new(:access_token => ACCESS_TOKEN)

      # cypress_json_path = 'config/cypress.json'
      # cypress_json_sha = client.content('holdenhinkle/vets-website', path: cypress_json_path).sha
      # cypress_json_content = client.content('holdenhinkle/vets-website', path: cypress_json_path, accept: 'application/vnd.github.V3.raw')

      # viewport_preset_js_path= 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js'
      # viewport_preset_js_sha = client.content('holdenhinkle/vets-website', path: viewport_preset_js_path).sha
      # viewport_preset_js_content = client.content('holdenhinkle/vets-website', path: viewport_preset_js_path, accept: 'application/vnd.github.V3.raw')
      
      # date = Date.today
      # date_string = "#{date.mon}_#{date.day}_#{date.year}"
      # ref = "heads/#{date_string}_update_cypress_viewport_data"

      # # CREATE BRANCH
      # # get sha of the last commit to base-off
      # sha = client.ref('holdenhinkle/vets-website', 'heads/master').object.sha
      # branch = client.create_ref('holdenhinkle/vets-website', ref, sha)

      # # UPDATE FILE
      # feature_branch = "#{date_string}_update_cypress_viewport_data"
      # client.update_contents("holdenhinkle/vets-website",
      #            cypress_json_path,
      #            "This is commit #1",
      #            cypress_json_sha,
      #            "cypress.json content goes here..",
      #            :branch => feature_branch)

      # client.update_contents("holdenhinkle/vets-website",
      #            viewport_preset_js_path,
      #            "This is commit #2",
      #            viewport_preset_js_sha,
      #            "viewportPreset.js content goes here...",
      #            :branch => feature_branch)
      
      # client.create_pull_request("holdenhinkle/vets-website",
      #   "master",
      #   feature_branch,
      #   "Update Cypress Viewport Data")
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
