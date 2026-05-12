# frozen_string_literal: true

require "fileutils"
require "tempfile"

module MergeZshHistory
  class Writer
    def write(path, content)
      expanded_path = File.expand_path(path)
      FileUtils.mkdir_p(File.dirname(expanded_path))

      Tempfile.create(["zsh-history-sync", ".tmp"], File.dirname(expanded_path)) do |file|
        file.write(content)
        file.flush
        file.fsync
        file.close
        File.rename(file.path, expanded_path)
      end
    end
  end
end
