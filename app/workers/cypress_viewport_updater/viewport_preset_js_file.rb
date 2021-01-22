# frozen_string_literal: true

module CypressViewportUpdater
  class ViewportPresetJsFile < ExistingGithubFile
    def initialize
      super(github_path: 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js',
            local_current_file_path: 'app/workers/cypress_viewport_updater/current_files/viewportPreset.js',
            local_updated_file_path: 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js',
            name: 'viewportPreset.js')
    end

    def update(viewports)
      create_local_current_file
      new_file = create_updated_viewport_preset_js_file

      File.open(local_current_file_path, 'r').each do |line|
        if /va-top-(mobile|tablet|desktop)-\d+/.match(line)
          if /va-top-(mobile|tablet|desktop)-1/.match(line)
            create_viewport_presets(line: line,
                                    viewports: viewports) do |preset|
                                      new_file.print preset
                                    end
          end
        else
          new_file.print line
        end
      end

      new_file.close
      self
    end

    private

    def create_updated_viewport_preset_js_file
      File.delete(local_updated_file_path) if File.exist?(local_updated_file_path)
      File.new(local_updated_file_path, 'w')
    end

    def create_viewport_presets(line:, viewports:)
      viewport_type = /(mobile|tablet|desktop)/.match(line)[0].to_sym

      viewports.send(viewport_type).each do |viewport|
        rank = viewport.rank
        width = viewport.width
        height = viewport.height
        yield("  'va-top-#{viewport_type}-#{rank}': { width: #{width}, height: #{height} },\n")
      end
    end
  end
end
