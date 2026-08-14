require "fileutils"
require "minitest/autorun"
require "open3"
require "pty"
require "timeout"
require "tmpdir"

class SlackContextTest < Minitest::Test
  SCRIPT = File.expand_path("../slack-context.rb", __dir__)

  def setup
    @directory = Dir.mktmpdir
    @bin = File.join(@directory, "bin")
    FileUtils.mkdir(@bin)
    @arguments = File.join(@directory, "arguments")
    @clipboard = File.join(@directory, "clipboard")
    @clipboard_count = File.join(@directory, "clipboard-count")
    @fetch_count = File.join(@directory, "fetch-count")
    write_fakes
    @env = {
      "PATH" => "#{@bin}:#{ENV.fetch("PATH")}",
      "SLACK_CONTEXT_TEST_ARGUMENTS" => @arguments,
      "SLACK_CONTEXT_TEST_CLIPBOARD" => @clipboard,
      "SLACK_CONTEXT_TEST_CLIPBOARD_COUNT" => @clipboard_count,
      "SLACK_CONTEXT_TEST_FETCH_COUNT" => @fetch_count,
    }
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_dumps_explicit_source_and_copies_json_paths
    output, status = run_script("-files=false", "https://example.slack.com/archives/test")

    assert_predicate status, :success?, output
    assert_equal ["dump", "-files=false", "https://example.slack.com/archives/test"], File.readlines(@arguments, chomp: true)
    assert_equal [File.join(File.realpath(@directory), "context.json")], File.readlines(@clipboard, chomp: true)
    refute_path_exists File.join(@directory, "slackdump-test.zip")
    assert_includes output, "Copied to clipboard:"
  end

  def test_uses_clipboard_as_source_when_no_arguments_are_given
    output, status = run_with_tty

    assert_predicate status, :success?, output
    assert_equal ["dump", "https://example.slack.com/archives/clipboard"], File.readlines(@arguments, chomp: true)
  end

  def test_copies_all_files_when_archive_has_no_json
    @env["SLACK_CONTEXT_TEST_NO_JSON"] = "1"

    _output, status = run_script("url")

    assert_predicate status, :success?
    assert_equal [File.join(File.realpath(@directory), "messages.txt")], File.readlines(@clipboard, chomp: true)
  end

  def test_fails_without_updating_clipboard_when_slackdump_fails
    @env["SLACK_CONTEXT_TEST_SLACKDUMP_FAIL"] = "1"

    _output, status = run_script("url")

    refute_predicate status, :success?
    refute_path_exists @clipboard
  end

  def test_fails_when_slackdump_does_not_create_an_archive
    @env["SLACK_CONTEXT_TEST_NO_ARCHIVE"] = "1"

    output, status = run_script("url")

    refute_predicate status, :success?
    assert_includes output, "slackdump did not create a new zip file"
    refute_path_exists @clipboard
  end

  def test_help_preserves_existing_usage
    output, status = run_script("--help")

    assert_predicate status, :success?
    assert_includes output, "Usage: slack-context [--interactive] [SLACKDUMP_DUMP_ARGS...]"
    refute_path_exists @arguments
  end

  def test_interactive_mode_refetches_and_quits
    output, status = run_interactive("rq")

    assert_predicate status, :success?, output
    assert_equal "2", File.read(@fetch_count)
    assert_equal "2", File.read(@clipboard_count)
  end

  def test_interactive_mode_refetches_with_enter
    output, status = run_interactive("\r", append_quit: true)

    assert_predicate status, :success?, output
    assert_equal "2", File.read(@fetch_count)
  end

  def test_interactive_mode_continues_after_a_failed_refetch
    @env["SLACK_CONTEXT_TEST_FAIL_ON"] = "2"

    output, status = run_interactive("rrq")

    assert_predicate status, :success?, output
    assert_equal "3", File.read(@fetch_count)
    assert_equal "2", File.read(@clipboard_count)
    assert_includes output, "fetch failed; clipboard was not updated"
  end

  def test_interactive_mode_recovers_after_archive_processing_fails
    @env["SLACK_CONTEXT_TEST_UNZIP_FAIL_ON"] = "2"

    output, status = run_interactive("rrq")

    assert_predicate status, :success?, output
    assert_equal "3", File.read(@fetch_count)
    assert_equal "2", File.read(@clipboard_count)
    assert_includes output, "unzip exited with status 31"
    refute_path_exists File.join(@directory, "slackdump-test.zip")
  end

  def test_archive_cleanup_failure_does_not_misreport_clipboard_state
    @env["SLACK_CONTEXT_TEST_READ_ONLY_DIRECTORY"] = "1"

    begin
      output, status = run_script("url")
    ensure
      FileUtils.chmod("u+w", @directory)
    end

    assert_predicate status, :success?, output
    assert_equal "1", File.read(@clipboard_count)
    assert_includes output, "could not remove slackdump-test.zip"
    refute_includes output, "clipboard was not updated"
  end

  def test_interactive_mode_exits_on_sigint
    output, status = run_interactive { |pid| Process.kill("INT", pid) }

    assert_predicate status, :success?, output
    assert_equal "1", File.read(@fetch_count)
  end

  def test_interactive_mode_exits_on_sigint_during_initial_fetch
    @env["SLACK_CONTEXT_TEST_INTERRUPT_ON_FETCH"] = "1"

    output, status = run_with_tty("--interactive", "url")

    assert_predicate status, :success?, output
    refute_includes output, "Interrupt"
  end

  def test_interactive_mode_rejects_non_tty_stdin
    output, status = run_script("--interactive", "url")

    refute_predicate status, :success?
    assert_includes output, "--interactive requires a terminal on stdin"
    refute_path_exists @fetch_count
  end

  private

  def run_script(*arguments)
    Open3.capture2e(@env, "ruby", SCRIPT, *arguments, chdir: @directory)
  end

  def run_with_tty(*arguments)
    output = +""
    status = nil

    PTY.spawn(@env, "ruby", SCRIPT, *arguments, chdir: @directory) do |reader, _writer, pid|
      begin
        output << reader.readpartial(4096) while true
      rescue EOFError, Errno::EIO
        nil
      end

      _, status = Process.wait2(pid)
    end

    [output, status]
  end

  def run_interactive(input = nil, append_quit: false)
    output = +""
    status = nil

    PTY.spawn(@env, "ruby", SCRIPT, "--interactive", "url", chdir: @directory) do |reader, writer, pid|
      Timeout.timeout(10) do
        output << reader.readpartial(4096) until output.include?("Press r or Enter")
        if block_given?
          yield(pid)
        else
          writer.write(input)
          if append_quit
            output << reader.readpartial(4096) until output.scan("Press r or Enter").length == 2
            writer.write("q")
          end
        end

        begin
          output << reader.readpartial(4096) while true
        rescue EOFError, Errno::EIO
          nil
        end

        _, status = Process.wait2(pid)
      end
    end

    [output, status]
  end

  def write_fakes
    write_executable("slackdump", <<~'SH')
      count=0
      if [[ -f ${SLACK_CONTEXT_TEST_FETCH_COUNT:?} ]]; then
        count=$(<"$SLACK_CONTEXT_TEST_FETCH_COUNT")
      fi
      count=$((count + 1))
      printf '%s' "$count" >"$SLACK_CONTEXT_TEST_FETCH_COUNT"
      printf '%s\n' "$@" >"${SLACK_CONTEXT_TEST_ARGUMENTS:?}"
      [[ ${SLACK_CONTEXT_TEST_SLACKDUMP_FAIL-} != 1 ]] || exit 23
      [[ ${SLACK_CONTEXT_TEST_FAIL_ON-} != "$count" ]] || exit 23
      if [[ ${SLACK_CONTEXT_TEST_INTERRUPT_ON_FETCH-} == 1 ]]; then
        kill -INT "$PPID"
        exit 130
      fi
      if [[ ${SLACK_CONTEXT_TEST_NO_ARCHIVE-} != 1 ]]; then
        printf '%*s' "$count" '' >slackdump-test.zip
      fi
    SH

    write_executable("unzip", <<~'SH')
      if [[ ${SLACK_CONTEXT_TEST_UNZIP_FAIL_ON-} == "$(<"${SLACK_CONTEXT_TEST_FETCH_COUNT:?}")" ]]; then
        exit 31
      fi
      if [[ $1 == -Z1 ]]; then
        if [[ ${SLACK_CONTEXT_TEST_NO_JSON-} == 1 ]]; then
          printf 'messages.txt\nfiles/\n'
        else
          printf 'context.json\nmessages.txt\nfiles/\n'
        fi
      elif [[ ${SLACK_CONTEXT_TEST_NO_JSON-} == 1 ]]; then
        printf 'messages\n' >messages.txt
      else
        printf '{}\n' >context.json
        printf 'messages\n' >messages.txt
      fi
    SH

    write_executable("cpath", <<~'SH')
      count=0
      if [[ -f ${SLACK_CONTEXT_TEST_CLIPBOARD_COUNT:?} ]]; then
        count=$(<"$SLACK_CONTEXT_TEST_CLIPBOARD_COUNT")
      fi
      printf '%s' "$((count + 1))" >"$SLACK_CONTEXT_TEST_CLIPBOARD_COUNT"
      printf '%s\n' "$@" >"${SLACK_CONTEXT_TEST_CLIPBOARD:?}"
      if [[ ${SLACK_CONTEXT_TEST_READ_ONLY_DIRECTORY-} == 1 ]]; then
        chmod a-w .
      fi
    SH

    write_executable("clip", <<~'SH')
      if [[ ! -t 0 ]]; then
        printf 'clip received non-TTY stdin\n' >&2
        exit 42
      fi
      printf 'https://example.slack.com/archives/clipboard\n'
    SH
  end

  def write_executable(name, body)
    path = File.join(@bin, name)
    File.write(path, "#!/usr/bin/env bash\n#{body}")
    FileUtils.chmod("u+x", path)
  end
end
