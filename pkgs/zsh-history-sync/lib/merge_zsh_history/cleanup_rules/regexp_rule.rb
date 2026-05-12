# frozen_string_literal: true

module MergeZshHistory
  module CleanupRules
    class RegexpRule
      def initialize(pattern)
        @pattern = pattern
      end

      def reason
        "regexp"
      end

      def match?(entry)
        @pattern.match?(entry.command)
      end
    end
  end
end
