# frozen_string_literal: true

module MergeZshHistory
  class Deduper
    def initialize
      @seen_keys = {}
    end

    def duplicate?(entry)
      key = [entry.start_time, entry.finish_time, entry.command]
      return true if @seen_keys.key?(key)

      @seen_keys[key] = true
      false
    end
  end
end
