# frozen_string_literal: true

module MergeZshHistory
  class Options < Struct.new(
    :sources,
    :output,
    :dry_run,
    :string_patterns,
    :regexp_patterns,
    :verbose,
    keyword_init: true
  )
    def cleanup?
      !rules.empty?
    end

    def rules
      @rules ||= build_rules.freeze
    end

    private

    def build_rules
      string_rules = string_patterns.map { |pattern| CleanupRules::StringRule.new(pattern) }
      regexp_rules = regexp_patterns.map { |pattern| CleanupRules::RegexpRule.new(pattern) }

      string_rules + regexp_rules
    end
  end
end
