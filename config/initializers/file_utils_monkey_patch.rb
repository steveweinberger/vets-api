# frozen_string_literal: true

require 'fileutils'
# rubocop:disable Naming/ClassAndModuleCamelCase
module FileUtils
  class Entry_
    def copy_file(dest)
      File.open(path) do |s|
        File.open(dest, 'wb', s.stat.mode) do |f|
          f.chmod f.lstat.mode
          IO.copy_stream(s, f)
        end
      end
    end
  end
end
# rubocop:enable Naming/ClassAndModuleCamelCase
