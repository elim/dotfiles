require "English"
require "io/console"
require "json"

module SlackContext
  class Error < StandardError
    attr_reader :status

    def initialize(message, status: 1)
      super(message)
      @status = status || 1
    end
  end

  class CommandRunner
    def run(*command)
      return if system(*command)

      raise command_error(command)
    end

    def capture(*command, stdin: nil)
      options = stdin ? { in: stdin } : {}
      output = IO.popen(command, "r", **options, &:read)
      raise command_error(command) unless $CHILD_STATUS.success?

      output
    rescue SystemCallError => e
      raise Error, "slack-context: #{e.message}"
    end

    private

    def command_error(command)
      status = $CHILD_STATUS
      description = status.signaled? ? "signal #{status.termsig}" : "status #{status.exitstatus}"
      Error.new("slack-context: #{command.first} exited with #{description}", status: status.exitstatus)
    end
  end

  class ConversationSummary
    EXCERPT_LENGTH = 200

    def self.load(path)
      payload = JSON.parse(File.read(path))
      return unless payload.is_a?(Hash)

      message = payload.fetch("messages", []).first
      return unless message.is_a?(Hash)

      new(
        channel_id: payload["channel_id"],
        channel_name: payload["name"],
        text: message["text"],
        path: path,
      )
    rescue JSON::ParserError, SystemCallError
      nil
    end

    def initialize(channel_id:, channel_name:, text:, path:)
      @channel_id = channel_id
      @channel_name = channel_name
      @text = text
      @path = path
    end

    def lines
      [channel_line, excerpt_line, "JSON: #{@path}"].compact
    end

    private

    def channel_line
      return if blank?(@channel_id) && blank?(@channel_name)
      return "Channel: ##{@channel_name} (#{@channel_id})" unless blank?(@channel_name) || blank?(@channel_id)
      return "Channel: ##{@channel_name}" unless blank?(@channel_name)

      "Channel: #{@channel_id}"
    end

    def excerpt_line
      return if blank?(@text)

      normalized = @text.gsub(/[[:space:]]+/, " ").strip
      excerpt = normalized.each_char.take(EXCERPT_LENGTH).join
      excerpt += "…" if normalized.length > EXCERPT_LENGTH
      "First message: #{excerpt}"
    end

    def blank?(value)
      !value.is_a?(String) || value.empty?
    end
  end

  class SummaryPresenter
    def initialize(output:)
      @output = output
    end

    def present(paths)
      paths.filter_map { |path| ConversationSummary.load(path) }.each do |summary|
        @output.puts "Fetched context:"
        summary.lines.each { |line| @output.puts line }
      end
    end
  end

  class Fetcher
    ARCHIVE_PATTERN = "slackdump*.zip"

    def initialize(runner:, error_output:, summary_presenter: SummaryPresenter.new(output: error_output))
      @runner = runner
      @error_output = error_output
      @summary_presenter = summary_presenter
    end

    def fetch(arguments)
      archive = dump(arguments)
      paths = extract(archive)
      @runner.run("cpath", *paths)

      @summary_presenter.present(paths)
      @error_output.puts "Copied to clipboard:"
      paths.each { |path| @error_output.puts path }
    ensure
      remove_archive(archive) if archive
    end

    private

    def dump(arguments)
      before = archives
      @runner.run("slackdump", "dump", *arguments)
      archive = changed_archive(before, archives)
      return archive if archive

      raise Error, "slack-context: slackdump did not create a new zip file"
    end

    def extract(archive)
      entries = @runner.capture("unzip", "-Z1", "--", archive).lines(chomp: true)
      file_paths = entries.reject { |entry| entry.end_with?("/") }.map { |entry| "./#{entry}" }
      json_paths = file_paths.grep(/\.json\z/)

      @runner.run("unzip", "-o", "--", archive)

      paths = json_paths.empty? ? file_paths : json_paths
      raise Error, "slack-context: zip file did not contain files" if paths.empty?

      paths.map { |path| File.realpath(path) }
    rescue SystemCallError => e
      raise Error, "slack-context: #{e.message}"
    end

    def archives
      Dir.glob(ARCHIVE_PATTERN).select { |path| File.file?(path) }.to_h do |path|
        stat = File.stat(path)
        [path, [stat.ino, stat.size, stat.mtime.to_r]]
      end
    end

    def changed_archive(before, after)
      after.keys.select { |path| before[path] != after[path] }.sort.last
    end

    def remove_archive(archive)
      File.delete(archive) if File.exist?(archive)
    rescue SystemCallError => e
      @error_output.puts "slack-context: could not remove #{archive}: #{e.message}"
    end
  end

  class CLI
    USAGE = <<~USAGE
      Usage: slack-context [--interactive] [SLACKDUMP_DUMP_ARGS...]

      Dump Slack content with slackdump, extract the archive, and copy the
      extracted JSON path(s) to the clipboard.

      With --interactive, press r or Enter to fetch again, or q or Ctrl-C
      to quit.

      Examples:
        slack-context
        slack-context -time-from 2026-07-03 -time-to 2026-07-04 "$(clip)"
        slack-context -files=false https://example.slack.com/archives/...
        slack-context --interactive https://example.slack.com/archives/...
    USAGE

    def initialize(arguments, input: $stdin, error_output: $stderr, runner: CommandRunner.new)
      @arguments = arguments.dup
      @input = input
      @error_output = error_output
      @runner = runner
      @fetcher = Fetcher.new(runner: runner, error_output: error_output)
    end

    def run
      interactive = @arguments.first == "--interactive"
      @arguments.shift if interactive

      return show_help if help?
      return fail_with("slack-context: --interactive requires a terminal on stdin") if interactive && !@input.tty?

      sources = @arguments.empty? ? [clipboard] : @arguments
      interactive ? run_interactively(sources) : fetch_once(sources)
    rescue Error => e
      report(e)
      e.status
    end

    private

    def help?
      @arguments.one? && ["-h", "--help"].include?(@arguments.first)
    end

    def show_help
      @error_output.puts USAGE
      0
    end

    def clipboard
      @runner.capture("clip", stdin: @input).sub(/\n+\z/, "")
    end

    def fetch_once(sources)
      @fetcher.fetch(sources)
      0
    end

    def run_interactively(sources)
      @fetcher.fetch(sources)

      loop do
        @error_output.print "Press r or Enter to fetch again, or q to quit: "
        key = @input.getch
        @error_output.puts

        case key
        when "r", "\r", "\n"
          refresh(sources)
        when "q"
          return 0
        end
      end
    rescue Interrupt
      @error_output.puts
      0
    end

    def refresh(sources)
      @fetcher.fetch(sources)
    rescue Error => e
      report(e)
      @error_output.puts "slack-context: fetch failed; clipboard was not updated"
    end

    def report(error)
      @error_output.puts error.message
    end

    def fail_with(message)
      @error_output.puts message
      1
    end
  end
end

exit SlackContext::CLI.new(ARGV).run
