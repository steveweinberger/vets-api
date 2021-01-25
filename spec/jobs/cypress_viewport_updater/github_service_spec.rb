# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::GithubService do
  before do
    VCR.use_cassette('cypress_viewport_updater/github_service') do
      @github = CypressViewportUpdater::GithubService.new
    end
  end

  it 'instantiates a new object' do
    expect(@github).to be_an_instance_of(described_class)
  end

  describe '#get_content' do
    # need file
    it 'fetches the sha of the given file and assigns it to the sha attribute of the file'
    it 'fetches the raw content of the given file and assign it to the raw_content attribute of the file'
  end

  describe '#create_branch' do
    it 'creates a new feature branch'
  end

  describe '#update_content' do
    # need file and content
  end

  describe '#submit_pr' do
  end
end
