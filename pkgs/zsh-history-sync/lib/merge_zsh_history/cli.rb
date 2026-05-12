# frozen_string_literal: true

require_relative "source"
require_relative "source_parser"
require_relative "fetched_source"
require_relative "fetcher"
require_relative "entry"
require_relative "history_utils"
require_relative "deduper"
require_relative "cleanup_rules/string_rule"
require_relative "cleanup_rules/regexp_rule"
require_relative "cleaner"
require_relative "dry_run_item"
require_relative "dry_run_reporter"
require_relative "writer"
require_relative "runner"
require_relative "options"
require_relative "options_parser"

module MergeZshHistory
  class Error < StandardError; end

  class CLI
    def self.start(argv, stdout: $stdout, stderr: $stderr)
      new(stdout: stdout, stderr: stderr).start(argv)
    end

    def initialize(stdout:, stderr:)
      @stdout = stdout
      @stderr = stderr
    end

    def start(argv)
      options = OptionsParser.new(stdout: @stdout).parse(argv)

      Runner.new(stdout: @stdout, stderr: @stderr).run(options)
    rescue OptionsParser::HelpRequested
      0
    rescue Error => e
      @stderr.puts("zsh-history-sync: #{e.message}")
      1
    end
  end
end
