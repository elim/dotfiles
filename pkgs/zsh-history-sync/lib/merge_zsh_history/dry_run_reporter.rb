# frozen_string_literal: true

require "json"

module MergeZshHistory
  class DryRunReporter
    def report(items, io:)
      items.each do |item|
        io.puts(
          [
            "[remove]",
            "reason=#{item.reasons.join(',')}",
            "source=#{item.entry.source_label}",
            "command=#{JSON.generate(item.entry.command)}",
          ].join(" "),
        )
      end
    end
  end
end
