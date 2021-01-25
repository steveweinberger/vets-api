# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::GithubService do
  describe '#new' do
    it 'returns a new instance' do
      VCR.use_cassette('cypress_viewport_updater/github_service') do
        @github = CypressViewportUpdater::GithubService.new
      end

      expect(@github).to be_an_instance_of(described_class)
    end
  end

  describe '#get_content' do
    # to-do: stub calling #get_content
    let!(:file) do
      CypressViewportUpdater::CypressJsonFile.new(
        github_path: 'config/cypress.json',
        local_current_file_path: 'app/workers/cypress_viewport_updater/current_files/cypress.json',
        local_updated_file_path: 'app/workers/cypress_viewport_updater/updated_files/cypress.json',
        name: 'cypress.json'
      )
    end

    before do
      VCR.use_cassette('cypress_viewport_updater/github_service_get_content') do
        CypressViewportUpdater::GithubService.new.get_content(file)
      end
    end

    it 'fetches the sha of the given file and assigns it to the sha attribute of the file' do
      expect(file.sha).to match(/\b[0-9a-f]{40}\b/)
    end

    it 'fetches the raw content of the given file and assign it to the raw_content attribute of the file' do
      expect(file.raw_content).to be_a(String)
    end
  end

  describe '#create_branch' do
    # to-do: stub calling #create_branch
    before do
      VCR.use_cassette('cypress_viewport_updater/github_service_create_branch') do
        @create_branch = CypressViewportUpdater::GithubService.new.create_branch
      end
    end

    it 'returns the sha the feature branch was was based off' do
      expect(@create_branch.object.sha).to match(/\b[0-9a-f]{40}\b/)
    end

    it 'returns the ref for the new feature branch' do
      expect(@create_branch.ref).to match(%r{refs\/heads\/[\d]+_update_cypress_viewport_data})
    end
  end

  describe '#update_content' do
    # to-do: stub calling #update_content
  end

  describe '#submit_pr' do
    # to-do: stub calling #submit_pr
  end
end
