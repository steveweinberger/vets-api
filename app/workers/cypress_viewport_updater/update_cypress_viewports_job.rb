# frozen_string_literal: true

module CypressViewportUpdater
  class UpdateCypressViewportsJob
    include Sidekiq::Worker

    START_DATE = Time.zone.today.prev_month.beginning_of_month
    END_DATE = Time.zone.today.prev_month.end_of_month

    def perform
      analytics = CypressViewportUpdater::GoogleAnalyticsReports
                  .new
                  .request_reports

      viewports = CypressViewportUpdater::Viewports
                  .new(user_report: analytics.user_report)
                  .create(viewport_report: analytics.viewport_report)

      github = CypressViewportUpdater::GithubService.new
      cypress_json_file = create_cypress_json_file
      viewport_preset_js_file = create_viewport_preset_js_file
      create_local_directories
      github.get_content(cypress_json_file)
      github.get_content(viewport_preset_js_file)
      github.create_branch

      [cypress_json_file, viewport_preset_js_file].each do |file|
        content = file.update(viewports).content
        github.update_content(file: file, content: content)
      end

      github.submit_pr
    end

    private

    def create_cypress_json_file
      CypressViewportUpdater::CypressJsonFile.new(
        github_path: 'config/cypress.json',
        local_current_file_path: 'app/workers/cypress_viewport_updater/current_files/cypress.json',
        local_updated_file_path: 'app/workers/cypress_viewport_updater/updated_files/cypress.json',
        name: 'cypress.json'
      )
    end

    def create_viewport_preset_js_file
      CypressViewportUpdater::ViewportPresetJsFile.new(
        github_path: 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js',
        local_current_file_path: 'app/workers/cypress_viewport_updater/current_files/viewportPreset.js',
        local_updated_file_path: 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js',
        name: 'viewportPreset.js'
      )
    end

    def create_local_directories
      current_files_directory = 'app/workers/cypress_viewport_updater/current_files'
      updated_files_directory = 'app/workers/cypress_viewport_updater/updated_files'

      [current_files_directory, updated_files_directory].each do |dirname|
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end
  end
end
