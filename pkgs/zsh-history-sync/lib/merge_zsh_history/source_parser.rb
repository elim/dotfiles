# frozen_string_literal: true

module MergeZshHistory
  class SourceParser
    SSH_SOURCE_PATTERN = /\A(?<remote>[^:\/\s]+):(?<path>[~\/].+)\z/

    def self.parse(raw)
      match = SSH_SOURCE_PATTERN.match(raw)
      return Source.new(kind: :ssh, label: raw, path: match[:path], remote: match[:remote]) if match

      Source.new(kind: :local, label: File.expand_path(raw), path: File.expand_path(raw))
    end
  end
end
