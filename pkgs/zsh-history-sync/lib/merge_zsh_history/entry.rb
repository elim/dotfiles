# frozen_string_literal: true

module MergeZshHistory
  class Entry < Struct.new(:start_time, :finish_time, :command, :source_label, keyword_init: true)
    def self.from_h(hash, source_label:)
      new(
        start_time: Integer(hash.fetch("start_time")),
        finish_time: Integer(hash.fetch("finish_time")),
        command: String(hash.fetch("command")),
        source_label: source_label,
      )
    end

    def to_h
      {
        "start_time" => start_time,
        "finish_time" => finish_time,
        "command" => command,
      }
    end
  end
end
