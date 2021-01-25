# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::ViewportPresetJsFile do
  github_path = 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js'
  local_current_file_path = 'app/workers/cypress_viewport_updater/current_files/viewportPreset.js'
  local_updated_file_path = 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js'
  name = 'viewportPreset.js'

  before do
    @file = described_class.new(github_path: github_path,
                                local_current_file_path: local_current_file_path,
                                local_updated_file_path: local_updated_file_path,
                                name: name)
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
          .get_content(@file)
      end

      current_files_directory = 'app/workers/cypress_viewport_updater/current_files'
      updated_files_directory = 'app/workers/cypress_viewport_updater/updated_files'

      [current_files_directory, updated_files_directory].each do |dirname|
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      end
    end

    it 'returns self' do
      object_id_before = @file.object_id
      object_id_after = @file.update(@viewports).object_id
      expect(object_id_before).to eq(object_id_after)
    end

    it 'saves a new file in the cypress_viewport_updater/updated_files directory' do
      # If tests run in parrallel, a race condition could exist here and cause tests
      # to be flaky because other tests access this directory.
      # However, I read that it's best to test whether a file is really being deleted
      # and created not make sure permissions are correct.
      # Thoughts?
      File.delete(@file.local_updated_file_path) if File.exist?(@file.local_updated_file_path)
      expect(File.exist?(@file.local_updated_file_path)).to be(false)

      @file.update(@viewports)
      expect(File.exist?(@file.local_updated_file_path)).to be(true)
    end

    it 'updates the file with the correct data' do
      lines = File.open(@file.local_updated_file_path, 'r').to_a

      lines.each_with_index do |line, outer_line_idx|
        if /va-top-(mobile|tablet|desktop)-1/.match(line)
          vp_type = /(mobile|tablet|desktop)/.match(line)[0].to_sym
          vp_data = @viewports.send(vp_type)
          vp_count = vp_data.count
          vp_index = 0
          outer_line_idx.upto(outer_line_idx + vp_count - 1) do |inner_line_idx|
            vp = vp_data[vp_index]
            preset = "  'va-top-#{vp_type}-#{vp.rank}': { width: #{vp.width}, height: #{vp.height} },\n"
            expect(lines[inner_line_idx]).to eq(preset)
            vp_index += 1
          end
        end
      end
    end
  end
end
