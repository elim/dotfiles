require "fileutils"
require "json"
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

  def test_displays_channel_and_truncated_root_message
    @env["SLACK_CONTEXT_TEST_LONG_MESSAGE"] = "1"

    output, status = run_script("url")

    assert_predicate status, :success?, output
    assert_includes output, "Channel: #example-channel (C0123456789)"
    assert_includes output, "First message: #{"a" * 200}…"
    assert_includes output, "JSON: #{File.realpath(@directory)}/context.json"
  end

  def test_ignores_invalid_json_when_displaying_summary
    @env["SLACK_CONTEXT_TEST_INVALID_JSON"] = "1"

    output, status = run_script("url")

    assert_predicate status, :success?, output
    refute_includes output, "Fetched context:"
    assert_includes output, "Copied to clipboard:"
  end

  def test_resolves_author_and_mentions_from_users_file
    write_users_file({
      "U012345678" => { "best_name" => "Example User" },
      "U987654321" => { "display_name" => "Mentioned User" },
    })

    output, status = run_script("--users-file", "users.json", "url")

    assert_predicate status, :success?, output
    assert_includes output, "Author: Example User (U012345678)"
    assert_includes output, "First message: hello @Mentioned User"
  end

  def test_discovers_workspace_config_from_parent_directory
    nested_directory = File.join(@directory, "work", "nested")
    FileUtils.mkdir_p(nested_directory)
    File.write(
      File.join(@directory, ".slack-context.json"),
      JSON.generate("users_file" => "state/users.json"),
    )
    write_users_file(
      { "U012345678" => { "best_name" => "Configured User" } },
      path: File.join(@directory, "state", "users.json"),
    )

    output, status = run_script("url", chdir: nested_directory)

    assert_predicate status, :success?, output
    assert_includes output, "Author: Configured User (U012345678)"
  end

  def test_uses_users_json_from_current_directory
    write_users_file({ "U012345678" => { "best_name" => "Local User" } })

    output, status = run_script("url")

    assert_predicate status, :success?, output
    assert_includes output, "Author: Local User (U012345678)"
  end

  def test_creates_user_map_from_embedded_dump_profiles
    @env["SLACK_CONTEXT_TEST_EMBEDDED_USERS"] = "1"

    output, status = run_script("--update-users-from-dump", "url")

    assert_predicate status, :success?, output
    users = JSON.parse(File.read(File.join(@directory, "users.json")))
    assert_equal "Root User", users.dig("U012345678", "best_name")
    assert_equal "Mentioned User", users.dig("U987654321", "best_name")
    assert_includes output, "Author: Root User (U012345678)"
    assert_includes output, "First message: hello @Mentioned User"
    assert_includes output, "Updated user map:"
  end

  def test_updates_user_map_without_discarding_existing_fields
    @env["SLACK_CONTEXT_TEST_EMBEDDED_USERS"] = "1"
    write_users_file({
      "U012345678" => {
        "best_name" => "Previous Name",
        "custom_field" => "preserved",
      },
      "U111111111" => { "best_name" => "Existing User" },
    })

    _output, status = run_script("--update-users-from-dump", "url")

    assert_predicate status, :success?
    users = JSON.parse(File.read(File.join(@directory, "users.json")))
    assert_equal "Root User", users.dig("U012345678", "best_name")
    assert_equal "preserved", users.dig("U012345678", "custom_field")
    assert_equal "Existing User", users.dig("U111111111", "best_name")
  end

  def test_does_not_create_user_map_without_update_option
    @env["SLACK_CONTEXT_TEST_EMBEDDED_USERS"] = "1"

    _output, status = run_script("url")

    assert_predicate status, :success?
    refute_path_exists File.join(@directory, "users.json")
  end

  def test_updates_configured_user_map
    File.write(
      File.join(@directory, ".slack-context.json"),
      JSON.generate("users_file" => "state/users.json"),
    )
    @env["SLACK_CONTEXT_TEST_EMBEDDED_USERS"] = "1"

    _output, status = run_script("--update-users-from-dump", "url")

    assert_predicate status, :success?
    assert_path_exists File.join(@directory, "state", "users.json")
    refute_path_exists File.join(@directory, "users.json")
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

  def run_script(*arguments, chdir: @directory)
    Open3.capture2e(@env, "ruby", SCRIPT, *arguments, chdir: chdir)
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
      elif [[ ${SLACK_CONTEXT_TEST_INVALID_JSON-} == 1 ]]; then
        printf 'not json\n' >context.json
      elif [[ ${SLACK_CONTEXT_TEST_LONG_MESSAGE-} == 1 ]]; then
        printf '{"channel_id":"C0123456789","name":"example-channel","messages":[{"user":"U012345678","text":"%s"}]}\n' \
          "$(printf '%0201d' 0 | tr 0 a)" >context.json
      elif [[ ${SLACK_CONTEXT_TEST_EMBEDDED_USERS-} == 1 ]]; then
        printf '%s\n' '{"channel_id":"C0123456789","name":"example-channel","users":[{"id":"U987654321","profile":{"display_name":"Mentioned User"}}],"messages":[{"user":"U012345678","user_profile":{"display_name":"Root User","real_name":"Root Example"},"text":"hello <@U987654321>"}]}' >context.json
      else
        printf '{"channel_id":"C0123456789","name":"example-channel","messages":[{"user":"U012345678","text":"hello <@U987654321>"}]}\n' >context.json
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

  def write_users_file(records, path: File.join(@directory, "users.json"))
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(records))
  end
end
