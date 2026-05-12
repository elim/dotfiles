# frozen_string_literal: true

require "minitest/autorun"
require "stringio"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "merge_zsh_history"

module MergeZshHistory
  class MergeZshHistoryTest < Minitest::Test
    def test_source_parser_parses_ssh_source
      source = SourceParser.parse("john@example.com:~/.zsh_history")

      assert_equal :ssh, source.kind
      assert_equal "john@example.com", source.remote
      assert_equal "~/.zsh_history", source.path
    end

    def test_source_parser_expands_local_path
      source = SourceParser.parse("~/tmp/history")

      assert_equal :local, source.kind
      assert_equal File.expand_path("~/tmp/history"), source.path
    end

    def test_source_parser_parses_ssh_alias_source
      source = SourceParser.parse("workstation:~/.zsh_history")

      assert_equal :ssh, source.kind
      assert_equal "workstation", source.remote
      assert_equal "~/.zsh_history", source.path
    end

    def test_options_build_cleanup_rules
      options = Options.new(
        sources: [],
        output: "./merged-zsh_history",
        dry_run: false,
        string_patterns: ["needle"],
        regexp_patterns: [/token/],
        verbose: false,
      )

      assert_equal 2, options.rules.size
      assert_predicate options, :cleanup?
    end

    def test_cleaner_collects_all_matching_reasons
      entry = Entry.new(
        start_time: 1,
        finish_time: 2,
        command: "echo token needle",
        source_label: "local",
      )
      cleaner = Cleaner.new(
        [
          CleanupRules::StringRule.new("needle"),
          CleanupRules::RegexpRule.new(/token/),
        ],
      )

      assert_equal %w[string regexp], cleaner.reasons_for(entry)
    end

    def test_deduper_detects_duplicate_entries
      deduper = Deduper.new
      entry = Entry.new(start_time: 1, finish_time: 2, command: "echo same", source_label: "a")
      duplicate = Entry.new(start_time: 1, finish_time: 2, command: "echo same", source_label: "b")

      refute deduper.duplicate?(entry)
      assert deduper.duplicate?(duplicate)
    end

    def test_deduper_keeps_same_command_with_different_finish_time
      deduper = Deduper.new
      entry = Entry.new(start_time: 1, finish_time: 2, command: "echo same", source_label: "a")
      different_duration = Entry.new(start_time: 1, finish_time: 3, command: "echo same", source_label: "b")

      refute deduper.duplicate?(entry)
      refute deduper.duplicate?(different_duration)
    end

    def test_dry_run_reporter_formats_entry
      entry = Entry.new(
        start_time: 1,
        finish_time: 2,
        command: "echo secret",
        source_label: "john@example.com:~/.zsh_history",
      )
      reporter = DryRunReporter.new
      io = StringIO.new

      reporter.report([DryRunItem.new(entry: entry, reasons: ["string"])], io: io)

      assert_equal(
        "[remove] reason=string source=john@example.com:~/.zsh_history command=\"echo secret\"\n",
        io.string,
      )
    end
  end
end
