# frozen_string_literal: true

require "optparse"

module MergeZshHistory
  class OptionsParser
    class HelpRequested < StandardError; end

    def initialize(stdout:)
      @stdout = stdout
    end

    def parse(argv)
      string_patterns = []
      regexp_patterns = []
      output = "./merged-zsh_history"
      dry_run = false
      verbose = false

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: zsh-history-sync [options] SOURCE [SOURCE ...]"
        opts.separator("")
        opts.separator("Duplicates with the same start time, finish time, and command are removed automatically.")

        opts.on("-o", "--output PATH", "Write merged history to PATH") do |value|
          output = value
        end

        opts.on("--dry-run", "Print entries that would be removed by cleanup or dedupe and exit") do
          dry_run = true
        end

        opts.on("--remove-string STRING", "Remove entries whose command includes STRING") do |value|
          string_patterns << value
        end

        opts.on("--remove-regexp REGEXP", "Remove entries whose command matches REGEXP") do |value|
          regexp_patterns << Regexp.new(value)
        rescue RegexpError => e
          raise OptionParser::InvalidArgument, "#{value}: #{e.message}"
        end

        opts.on("--verbose", "Print progress to stderr") do
          verbose = true
        end

        opts.on("-h", "--help", "Print this help") do
          @stdout.puts(opts)
          raise HelpRequested
        end
      end

      raw_sources = parser.parse(argv)
      raise Error, "at least one SOURCE is required\n#{parser}" if raw_sources.empty?

      Options.new(
        sources: raw_sources.map { |source| SourceParser.parse(source) },
        output: output,
        dry_run: dry_run,
        string_patterns: string_patterns,
        regexp_patterns: regexp_patterns,
        verbose: verbose,
      )
    rescue OptionParser::ParseError => e
      raise Error, "#{e.message}\n#{parser}"
    end
  end
end
