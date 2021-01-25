# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an existing file' do
  describe '#github_path' do
    it 'returns the correct value' do
      expect(@file.github_path).to eq(github_path)
    end
  end

  describe '#local_current_file_path' do
    it 'returns the correct value' do
      expect(@file.local_current_file_path).to eq(local_current_file_path)
    end
  end

  describe '#local_updated_file_path' do
    it 'returns the correct value' do
      expect(@file.local_updated_file_path).to eq(local_updated_file_path)
    end
  end

  describe '#name' do
    it 'returns the correct value' do
      expect(@file.name).to eq(name)
    end
  end

  describe '#sha' do
    it 'returns the correct value' do
      sha = '16C79BBE876272C7C47DB5C3E63FA220B4BC02CF'
      @file.sha = sha
      expect(@file.sha).to eq(sha)
    end
  end

  describe '#sha=' do
    it 'returns the correct value when it is updated' do
      sha_1 = '16C79BBE876272C7C47DB5C3E63FA220B4BC02CF'
      @file.sha = sha_1
      expect(@file.sha).to eq(sha_1)

      sha_2 = '72A707E23BF1EAC3BD7ABFF9C7CB26897ECB12F1'
      @file.sha = sha_2
      expect(@file.sha).to eq(sha_2)
    end
  end

  describe '#raw_content' do
    it 'returns the correct value' do
      raw_content = 'Some raw content'
      @file.raw_content = raw_content
      expect(@file.raw_content).to eq(raw_content)
    end
  end

  describe '#raw_content=' do
    it 'returns the correct value when it is updated' do
      raw_content_1 = 'Some raw content'
      @file.raw_content = raw_content_1
      expect(@file.raw_content).to eq(raw_content_1)

      raw_content_2 = 'Some different raw content'
      @file.raw_content = raw_content_2
      expect(@file.raw_content).to eq(raw_content_2)
    end
  end

  describe '#create_local_current_file' do
    before do
      current_files_directory = 'app/workers/cypress_viewport_updater/current_files'
      FileUtils.mkdir_p(current_files_directory) unless File.directory?(current_files_directory)
    end

    it 'deletes a file if it exists' do
      # this tests part of what the method does internally, but does it satisfy SimpleCov?
      File.delete(local_current_file_path) if File.exist?(local_current_file_path)

      raw_content_1 = 'Raw content 1'
      File.write(@file.local_current_file_path, raw_content_1)
      File.read(@file.local_current_file_path)

      raw_content_2 = 'Raw content 2'
      @file.raw_content = raw_content_2
      @file.create_local_current_file
      expect(File.read(@file.local_current_file_path)).to eq(raw_content_2)
    end

    it 'creates a file' do
      # this tests part of what the method does internally, but does it satisfy SimpleCov?
      File.delete(local_current_file_path) if File.exist?(local_current_file_path)

      raw_content = 'Raw content'
      @file.raw_content = raw_content
      @file.create_local_current_file
      expect(File.exist?(local_current_file_path)).to be(true)
    end
  end

  describe '#content' do
    it 'returns the content from local_updated_file_path' do
      updated_files_directory = 'app/workers/cypress_viewport_updater/updated_files'
      FileUtils.mkdir_p(updated_files_directory) unless File.directory?(updated_files_directory)
      File.delete(local_updated_file_path) if File.exist?(local_updated_file_path)
      updated_content = 'Updated content'
      File.write(local_updated_file_path, updated_content)
      expect(@file.content).to eq(updated_content)
    end
  end
end

context CypressViewportUpdater::ExistingGithubFile do
  let!(:github_path) { 'config/cypress.json' }
  let!(:local_current_file_path) { 'app/workers/cypress_viewport_updater/current_files/cypress.json' }
  let!(:local_updated_file_path) { 'app/workers/cypress_viewport_updater/updated_files/cypress.json' }
  let!(:name) { 'cypress.json' }

  before do
    @file = described_class.new(github_path: github_path,
                                local_current_file_path: local_current_file_path,
                                local_updated_file_path: local_updated_file_path,
                                name: name)
  end

  it_behaves_like 'an existing file'
end

context CypressViewportUpdater::CypressJsonFile do
  let!(:github_path) { 'config/cypress.json' }
  let!(:local_current_file_path) { 'app/workers/cypress_viewport_updater/current_files/cypress.json' }
  let!(:local_updated_file_path) { 'app/workers/cypress_viewport_updater/updated_files/cypress.json' }
  let!(:name) { 'cypress.json' }

  before do
    @file = described_class.new(github_path: github_path,
                                local_current_file_path: local_current_file_path,
                                local_updated_file_path: local_updated_file_path,
                                name: name)
  end

  it_behaves_like 'an existing file'
end

context CypressViewportUpdater::ViewportPresetJsFile do
  let!(:github_path) { 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js' }
  let!(:local_current_file_path) { 'app/workers/cypress_viewport_updater/current_files/viewportPreset.js' }
  let!(:local_updated_file_path) { 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js' }
  let!(:name) { 'viewportPreset.js' }

  before do
    @file = described_class.new(github_path: github_path,
                                local_current_file_path: local_current_file_path,
                                local_updated_file_path: local_updated_file_path,
                                name: name)
  end

  it_behaves_like 'an existing file'
end
