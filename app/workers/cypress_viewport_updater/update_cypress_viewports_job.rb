# frozen_string_literal: true

module CypressViewportUpdater
  class UpdateCypressViewportsJob
    include Sidekiq::Worker

    START_DATE = Time.zone.today.prev_month.beginning_of_month
    END_DATE = Time.zone.today.prev_month.end_of_month

    def perform
      analytics = CypressViewportUpdater::GoogleAnalyticsReports.new
      reports = analytics.request_reports

      viewport_collection = CypressViewportUpdater::ViewportCollection.new(user_report: reports[0])
      viewport_collection.create(viewport_report: reports[1])

      github = CypressViewportUpdater::GithubService.new
      cypress_json_file = CypressViewportUpdater::CypressJsonFile.new
      viewport_preset_js_file = CypressViewportUpdater::ViewportPresetJsFile.new
      create_local_directories
      github.get_content(cypress_json_file)
      github.get_content(viewport_preset_js_file)
      github.create_branch

      [cypress_json_file, viewport_preset_js_file].each do |file|
        content = file.update(viewport_collection).content
        github.update_content(file: file, content: content)
      end

      github.submit_pr
    end

    private

    def create_local_directories
      current_files_directory = 'app/workers/cypress_viewport_updater/current_files'
      updated_files_directory = 'app/workers/cypress_viewport_updater/updated_files'

      [current_files_directory, updated_files_directory].each do |dirname|
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end
  end
end
