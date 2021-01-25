# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::CypressJsonFile do
  github_path = 'config/cypress.json'
  local_current_file_path = 'app/workers/cypress_viewport_updater/current_files/cypress.json'
  local_updated_file_path = 'app/workers/cypress_viewport_updater/updated_files/cypress.json'
  name = 'cypress.json'

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

      VCR.use_cassette('cypress_viewport_updater/github_get_cypress_json_file') do
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

    it 'creates the correct number of mobile viewport objects' do
      required_number = CypressViewportUpdater::Viewports::NUM_TOP_VIEWPORTS[:mobile]
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      actual_number = file_as_hash['env']['vaTopMobileViewports'].count
      expect(required_number).to eq(actual_number)
    end

    it 'creates the correct number of tablet viewport objects' do
      required_number = CypressViewportUpdater::Viewports::NUM_TOP_VIEWPORTS[:tablet]
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      actual_number = file_as_hash['env']['vaTopTabletViewports'].count
      expect(required_number).to eq(actual_number)
    end

    it 'creates the correct number of desktop viewport objects' do
      required_number = CypressViewportUpdater::Viewports::NUM_TOP_VIEWPORTS[:desktop]
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      actual_number = file_as_hash['env']['vaTopDesktopViewports'].count
      expect(required_number).to eq(actual_number)
    end

    it 'creates mobile viewport objects with the correct data' do
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      mobile_viewports = file_as_hash['env']['vaTopMobileViewports']

      if @viewports.mobile.count == mobile_viewports.count
        @viewports.mobile.each_with_index do |new_data, i|
          data_in_file = mobile_viewports[i]
          expect(new_data.viewportPreset).to eq(data_in_file['viewportPreset'])
          expect(new_data.rank).to eq(data_in_file['rank'])
          expect(new_data.width).to eq(data_in_file['width'])
          expect(new_data.height).to eq(data_in_file['height'])
        end
      else
        # fail the test
        expect(@viewports.mobile.count).to eq(mobile_viewports.count)
      end
    end

    it 'creates tablet viewport objects with the correct data' do
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      tablet_viewports = file_as_hash['env']['vaTopTabletViewports']

      if @viewports.tablet.count == tablet_viewports.count
        @viewports.tablet.each_with_index do |new_data, i|
          data_in_file = tablet_viewports[i]
          expect(new_data.viewportPreset).to eq(data_in_file['viewportPreset'])
          expect(new_data.rank).to eq(data_in_file['rank'])
          expect(new_data.width).to eq(data_in_file['width'])
          expect(new_data.height).to eq(data_in_file['height'])
        end
      else
        # fail the test
        expect(@viewports.tablet.count).to eq(tablet_viewports.count)
      end
    end

    it 'creates desktop viewport objects with the correct data' do
      file_as_hash = JSON.parse(File.read(@file.local_updated_file_path))
      desktop_viewports = file_as_hash['env']['vaTopDesktopViewports']

      if @viewports.desktop.count == desktop_viewports.count
        @viewports.desktop.each_with_index do |new_data, i|
          data_in_file = desktop_viewports[i]
          expect(new_data.viewportPreset).to eq(data_in_file['viewportPreset'])
          expect(new_data.rank).to eq(data_in_file['rank'])
          expect(new_data.width).to eq(data_in_file['width'])
          expect(new_data.height).to eq(data_in_file['height'])
        end
      else
        # fail the test
        expect(@viewports.desktop.count).to eq(desktop_viewports.count)
      end
    end
  end
end
