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
      github = CypressViewportUpdater::GithubService.new
      cypress_json_file = CypressViewportUpdater::CypressJsonFile.new
      viewport_preset_js_file = CypressViewportUpdater::ViewportPresetJsFile.new
      github.get_content(cypress_json_file)
      github.get_content(viewport_preset_js_file)
      github.create_branch
      updated_cypress_json_file_content = cypress_json_file.update(viewport_collection).content
      github.update_content(cypress_json_file, updated_cypress_json_file_content)
      updated_viewport_preset_js_file_content = viewport_preset_js_file.update(viewport_collection).content
      github.update_content(viewport_preset_js_file, updated_viewport_preset_js_file_content)
      github.submit_pr
    end
  end
end
