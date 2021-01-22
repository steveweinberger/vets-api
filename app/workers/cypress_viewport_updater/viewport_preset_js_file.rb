# frozen_string_literal: true

module CypressViewportUpdater
  class ViewportPresetJsFile < ExistingGithubFile
    def initialize
      super(github_path: 'src/platform/testing/e2e/cypress/support/commands/viewportPreset.js',
            local_current_file_path: 'app/workers/cypress_viewport_updater/current_files/viewportPreset.js',
            local_updated_file_path: 'app/workers/cypress_viewport_updater/updated_files/viewportPreset.js',
            name: 'viewportPreset.js')
    end

    def update(collection)
      create_local_current_file
      new_file = create_updated_viewport_preset_js_file

      File.open(local_current_file_path, 'r').each do |line|
        if /va-top-(mobile|tablet|desktop)-\d+/.match(line)
          if /va-top-(mobile|tablet|desktop)-1/.match(line)
            print_viewport_presets(file: new_file,
                                   line: line,
                                   collection: collection)
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

    def print_viewport_presets(file:, line:, collection:)
      viewport_type = /(mobile|tablet|desktop)/.match(line)[0]
      viewports = collection.viewports[viewport_type.to_sym]

      viewports.each do |viewport|
        rank = viewport.rank
        width = viewport.width
        height = viewport.height
        preset = "  'va-top-#{viewport_type}-#{rank}': { width: #{width}, height: #{height} },\n"
        file.print preset
      end
    end
  end
end
