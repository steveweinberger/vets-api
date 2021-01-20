# frozen_string_literal: true

module CypressViewportUpdater
  class ExistingGithubFile
    attr_reader :github_path, :local_current_file_path, :local_updated_file_path, :name
    attr_accessor :sha, :raw_content

    def initialize(github_path:, local_current_file_path:, local_updated_file_path:, name:)
      @github_path = github_path
      @local_current_file_path = local_current_file_path
      @local_updated_file_path = local_updated_file_path
      @name = name
    end

    def create_local_current_file
      File.delete(local_current_file_path) if File.exist?(local_current_file_path)
      File.write(local_current_file_path, raw_content)
    end

    def content
      File.read(local_updated_file_path)
    end
  end
end
