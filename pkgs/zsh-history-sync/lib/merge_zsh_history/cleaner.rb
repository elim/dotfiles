# frozen_string_literal: true

module MergeZshHistory
  class Cleaner
    def initialize(rules)
      @rules = rules
    end

    def reasons_for(entry)
      @rules.filter_map { |rule| rule.reason if rule.match?(entry) }
    end
  end
end
