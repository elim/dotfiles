# frozen_string_literal: true

require "tmpdir"

module MergeZshHistory
  class Runner
    def initialize(
      stdout:,
      stderr:,
      fetcher: Fetcher.new,
      history_utils: HistoryUtils.new,
      reporter: DryRunReporter.new,
      writer: Writer.new
    )
      @stdout = stdout
      @stderr = stderr
      @fetcher = fetcher
      @history_utils = history_utils
      @reporter = reporter
      @writer = writer
    end

    def run(options)
      Dir.mktmpdir("zsh-history-sync") do |workspace|
        fetched_sources = @fetcher.fetch(options.sources, workspace: workspace)
        removed_items, filtered_paths = filter_sources(fetched_sources, options, workspace)

        if options.dry_run
          @reporter.report(removed_items, io: @stdout)
          verbose(options, "dry-run: #{removed_items.count} entries would be removed")
          return 0
        end

        merged_history = @history_utils.merge(filtered_paths)
        @writer.write(options.output, merged_history)
        verbose(options, "wrote merged history to #{File.expand_path(options.output)}")

        0
      end
    end

    private

    def filter_sources(fetched_sources, options, workspace)
      cleaner = Cleaner.new(options.rules)
      deduper = Deduper.new
      filtered_paths = []
      removed_items = []

      fetched_sources.each_with_index do |fetched_source, index|
        entries = @history_utils.decode(fetched_source.path, source_label: fetched_source.source.label)

        kept_entries, removed_for_source = partition_entries(entries, cleaner, deduper)
        removed_items.concat(removed_for_source)

        filtered_history = @history_utils.encode(
          kept_entries,
          workspace: workspace,
          basename: format("filtered-%02d", index),
        )

        filtered_path = File.join(workspace, format("filtered-%02d.zsh_history", index))
        File.write(filtered_path, filtered_history)
        filtered_paths << filtered_path
      end

      [removed_items, filtered_paths]
    end

    def partition_entries(entries, cleaner, deduper)
      kept_entries = []
      removed_items = []

      entries.each do |entry|
        reasons = cleaner.reasons_for(entry)
        reasons << "duplicate" if deduper.duplicate?(entry)

        if reasons.empty?
          kept_entries << entry
        else
          removed_items << DryRunItem.new(entry: entry, reasons: reasons)
        end
      end

      [kept_entries, removed_items]
    end

    def verbose(options, message)
      return unless options.verbose

      @stderr.puts(message)
    end
  end
end
