require "English"
require "io/console"
require "open3"

class FetchError < StandardError
  attr_reader :status

  def initialize(status, message = nil)
    super(message || "")
    @status = status || 1
  end
end

def usage
  warn <<~USAGE
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
end

def zip_files
  Dir.glob("slackdump*.zip").select { |path| File.file?(path) }.sort
end

def run_command(*command)
  return if system(*command)

  raise FetchError, $CHILD_STATUS.exitstatus
end

def fetch_context(arguments)
  before = zip_files
  run_command("slackdump", "dump", *arguments)

  zip_file = (zip_files - before).last
  unless zip_file
    raise FetchError.new(1, "slack-context: slackdump did not create a new zip file")
  end

  entries_output, status = Open3.capture2("unzip", "-Z1", "--", zip_file)
  raise FetchError, status.exitstatus unless status.success?

  file_paths = entries_output.lines(chomp: true)
    .reject { |entry| entry.end_with?("/") }
    .map { |entry| "./#{entry}" }
  json_paths = file_paths.select { |path| path.end_with?(".json") }

  run_command("unzip", "-o", "--", zip_file)

  copied_paths = (json_paths.empty? ? file_paths : json_paths).map do |path|
    File.realpath(path)
  end

  if copied_paths.empty?
    raise FetchError.new(1, "slack-context: zip file did not contain files")
  end

  run_command("cpath", *copied_paths)
  File.delete(zip_file)

  warn "Copied to clipboard:"
  copied_paths.each { |path| warn path }
rescue SystemCallError => e
  raise FetchError.new(1, "slack-context: #{e.message}")
end

interactive = ARGV.first == "--interactive"
ARGV.shift if interactive

if ARGV.one? && ["-h", "--help"].include?(ARGV.first)
  usage
  exit
end

if interactive && !$stdin.tty?
  warn "slack-context: --interactive requires a terminal on stdin"
  exit 1
end

if ARGV.empty?
  clipboard = IO.popen(["clip"], "r", in: $stdin, &:read)
  status = $CHILD_STATUS
  exit status.exitstatus unless status.success?

  ARGV.replace([clipboard.sub(/\n+\z/, "")])
end

begin
  fetch_context(ARGV)
rescue FetchError => e
  warn e.message unless e.message.empty?
  exit e.status
end

exit unless interactive

begin
  loop do
    warn "Press r or Enter to fetch again, or q to quit: "
    key = $stdin.getch

    case key
    when "r", "\r", "\n"
      begin
        fetch_context(ARGV)
      rescue FetchError => e
        warn e.message unless e.message.empty?
        warn "slack-context: fetch failed; clipboard was not updated"
      end
    when "q"
      exit
    end
  end
rescue Interrupt
  warn
  exit
end
