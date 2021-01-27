# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::ViewportPresetJsFile do
  VCR.configure do |c|
    %w[
      https://api.github.com/repos/holdenhinkle/vets-website/contents/config/cypress.json
      https://api.github.com/repos/holdenhinkle/vets-website/contents/src/platform/testing/e2e/cypress/support/commands/viewportPreset.js
      https://api.github.com/repos/holdenhinkle/vets-website/git/refs
      https://api.github.com/repos/holdenhinkle/vets-website/git/refs/heads/master
      https://api.github.com/repos/holdenhinkle/vets-website/pulls
    ].each do |key|
      data = YAML.safe_load(File.open('config/settings.local.yml'))
      c.filter_sensitive_data('Removed') { data[key] }
    end
  end
  
  before do
    @file = described_class.new
  end

  it { expect(described_class).to be < CypressViewportUpdater::ExistingGithubFile }

  describe '#update' do
    before do
      google = VCR.use_cassette('cypress_viewport_updater/google_analytics_after_request_report') do
        CypressViewportUpdater::GoogleAnalyticsReports
          .new
          .request_reports
      end

      @viewports = CypressViewportUpdater::Viewports
                   .new(user_report: google.user_report)
                   .create(viewport_report: google.viewport_report)

      VCR.use_cassette('cypress_viewport_updater/github_get_viewport_preset_js_file') do
        CypressViewportUpdater::GithubService
          .new
          .get_content(file: @file)
      end
    end

    it 'returns self' do
      object_id_before = @file.object_id
      object_id_after = @file.update(viewports: @viewports).object_id
      expect(object_id_before).to eq(object_id_after)
    end

    it 'saves the updated data to updated_content' do
      expect(@file.updated_content).to be_nil
      @file.update(viewports: @viewports)
      expect(@file.updated_content).not_to be_nil
    end

    it 'creates presets with the correct data' do
      lines = @file.update(viewports: @viewports).updated_content.split("\n")

      lines.each_with_index do |line, line_index|
        if /va-top-(mobile|tablet|desktop)-1/.match(line)
          vp_type = /(mobile|tablet|desktop)/.match(line)[0].to_sym
          vp_data = @viewports.send(vp_type)
          vp_count = vp_data.count
          vp_data_index = 0
          line_index.upto(line_index + vp_count - 1) do |vp_type_line_index|
            vp = vp_data[vp_data_index]
            preset = "  'va-top-#{vp_type}-#{vp.rank}': { width: #{vp.width}, height: #{vp.height} },"
            expect(lines[vp_type_line_index]).to eq(preset)
            vp_data_index += 1
          end
        end
      end
    end
  end
end
