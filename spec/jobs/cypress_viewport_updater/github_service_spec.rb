# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::GithubService do
  describe '#new' do
    it 'returns a new instance' do
      github = nil

      VCR.use_cassette('cypress_viewport_updater/github_service_new') do
        github = CypressViewportUpdater::GithubService.new
      end

      expect(github).to be_an_instance_of(described_class)
    end
  end

  describe '#get_content' do
    let!(:file) { CypressViewportUpdater::CypressJsonFile.new }

    before do
      VCR.use_cassette('cypress_viewport_updater/github_service_get_content') do
        CypressViewportUpdater::GithubService.new.get_content(file: file)
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
    let!(:file) { CypressViewportUpdater::CypressJsonFile.new }

    before do
      github = nil

      VCR.use_cassette('cypress_viewport_updater/github_service_update_content_new') do
        github = CypressViewportUpdater::GithubService.new
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_update_content_get_content') do
        github = github.get_content(file: file)
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_update_content_create_branch') do
        github.create_branch
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_update') do
        file.updated_content = 'Updated content'
        @update_content = github.update_content(file: file)
      end
    end

    it 'returns the name of the file' do
      expect(@update_content.content.name).to eq(file.name)
    end

    it 'returns the github file path' do
      expect(@update_content.content.path).to eq(file.github_path)
    end
  end

  describe '#submit_pr' do
    before do
      file_1 = CypressViewportUpdater::CypressJsonFile.new
      file_2 = CypressViewportUpdater::ViewportPresetJsFile.new
      github = nil

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_new') do
        github = CypressViewportUpdater::GithubService.new
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_get_content_file_1') do
        github.get_content(file: file_1)
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_get_content_file_2') do
        github.get_content(file: file_2)
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_create_branch') do
        github.create_branch
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_update_content_file_1') do
        file_1.updated_content = 'File 1 content'
        github.update_content(file: file_1)
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr_update_content_file_2') do
        file_2.updated_content = 'File 2 content'
        github.update_content(file: file_2)
      end

      VCR.use_cassette('cypress_viewport_updater/github_service_submit_pr') do
        @submit_pr = github.submit_pr
      end
    end

    it 'submits a pr to the department-of-veterans-affairs/vets-website repo' do
      expect(@submit_pr.base.repo.full_name).to eq('holdenhinkle/vets-website')
      # expect(@submit_pr.base.repo.full_name).to eq('department-of-veterans-affairs/vets-website')
    end

    it 'returns the number of commits in the repo' do
      expect(@submit_pr.commits).to eq(2)
    end

    it 'returns the url to the pr' do
      expect(@submit_pr.url)
        .to match(%r{\bhttps:\/\/api.github.com\/repos\/holdenhinkle\/vets-website\/pulls\/\d+\b})
      # expect(@submit_pr)
      #   .to match(%r{\bhttps:\/\/api.github.com\/repos\/department-of-veterans-affairs\/vets-website\/pulls\/\d+\b})
    end

    it 'returns the pr title' do
      expect(@submit_pr.title).not_to eq('')
    end

    it 'returns the pr body' do
      expect(@submit_pr.body).not_to eq('')
    end
  end
end
