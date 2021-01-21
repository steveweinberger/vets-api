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

    def create_current_files_directory
      dirname = File.dirname(local_current_file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end

    def create_updated_files_directory
      dirname = File.dirname(local_updated_file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
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
