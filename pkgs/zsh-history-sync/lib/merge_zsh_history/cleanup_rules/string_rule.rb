# frozen_string_literal: true

module MergeZshHistory
  module CleanupRules
    class StringRule
      def initialize(pattern)
        @pattern = pattern
      end

      def reason
        "string"
      end

      def match?(entry)
        entry.command.include?(@pattern)
      end
    end
  end
end
