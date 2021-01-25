# frozen_string_literal: true

module CypressViewportUpdater
  class CypressJsonFile < ExistingGithubFile
    def initialize(github_path:, local_current_file_path:, local_updated_file_path:, name:)
      super(github_path: github_path,
            local_current_file_path: local_current_file_path,
            local_updated_file_path: local_updated_file_path,
            name: name)
    end

    def update(viewports)
      create_local_current_file
      file_as_hash = JSON.parse(File.read(local_current_file_path))
      update_viewports(hash: file_as_hash, viewports: viewports)
      File.delete(local_updated_file_path) if File.exist?(local_updated_file_path)
      File.write(local_updated_file_path, JSON.pretty_generate(JSON.parse(file_as_hash.to_json)))
      self
    end

    private

    def update_viewports(hash:, viewports:)
      hash['env']['vaTopMobileViewports'] = viewports.mobile
      hash['env']['vaTopTabletViewports'] = viewports.tablet
      hash['env']['vaTopDesktopViewports'] = viewports.desktop
    end
  end
end
