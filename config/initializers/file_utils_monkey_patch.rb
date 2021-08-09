# frozen_string_literal: true

require 'fileutils'
FileUtils.Entry_.module_eval do
  def copy_file(dest)
    File.open(path) do |s|
      File.open(dest, 'wb', s.stat.mode) do |f|
        IO.copy_stream(s, f)
        f.chmod f.lstat.mode
      end
    end
  end
end
