# frozen_string_literal: true

require "json"
require "open3"

module MergeZshHistory
  class HistoryUtils
    def decode(path, source_label:)
      stdout = run!("zsh-history-utils", "decode", path)

      stdout.each_line.filter_map do |line|
        stripped = line.strip
        next if stripped.empty?

        Entry.from_h(JSON.parse(stripped), source_label: source_label)
      end
    end

    def encode(entries, workspace:, basename:)
      jsonl_path = File.join(workspace, "#{basename}.jsonl")

      File.open(jsonl_path, "w") do |file|
        entries.each do |entry|
          file.puts(JSON.generate(entry.to_h))
        end
      end

      run!("zsh-history-utils", "encode", jsonl_path)
    end

    def merge(paths)
      run!("zsh-history-utils", "merge", *paths)
    end

    private

    def run!(*command)
      stdout, stderr, status = Open3.capture3(*command)
      return stdout if status.success?

      message = stderr.strip
      raise Error, message.empty? ? "command failed: #{command.join(' ')}" : message
    end
  end
end
