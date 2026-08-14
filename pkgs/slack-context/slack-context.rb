require "English"
require "open3"

def usage
  warn <<~USAGE
    Usage: slack-context [SLACKDUMP_DUMP_ARGS...]

    Dump Slack content with slackdump, extract the archive, and copy the
    extracted JSON path(s) to the clipboard.

    Examples:
      slack-context
      slack-context -time-from 2026-07-03 -time-to 2026-07-04 "$(clip)"
      slack-context -files=false https://example.slack.com/archives/...
  USAGE
end

def zip_files
  Dir.glob("slackdump*.zip").select { |path| File.file?(path) }.sort
end

if ARGV.one? && ["-h", "--help"].include?(ARGV.first)
  usage
  exit
end

if ARGV.empty?
  clipboard, status = Open3.capture2("clip")
  exit status.exitstatus unless status.success?

  ARGV.replace([clipboard.sub(/\n+\z/, "")])
end

before = zip_files
exit $CHILD_STATUS.exitstatus unless system("slackdump", "dump", *ARGV)

zip_file = (zip_files - before).last
unless zip_file
  warn "slack-context: slackdump did not create a new zip file"
  exit 1
end

entries_output, status = Open3.capture2("unzip", "-Z1", "--", zip_file)
exit status.exitstatus unless status.success?

file_paths = entries_output.lines(chomp: true)
  .reject { |entry| entry.end_with?("/") }
  .map { |entry| "./#{entry}" }
json_paths = file_paths.select { |path| path.end_with?(".json") }

exit $CHILD_STATUS.exitstatus unless system("unzip", "-o", "--", zip_file)

copied_paths = (json_paths.empty? ? file_paths : json_paths).map do |path|
  File.realpath(path)
end

if copied_paths.empty?
  warn "slack-context: zip file did not contain files"
  exit 1
end

exit $CHILD_STATUS.exitstatus unless system("cpath", *copied_paths)

File.delete(zip_file)

warn "Copied to clipboard:"
copied_paths.each { |path| warn path }
