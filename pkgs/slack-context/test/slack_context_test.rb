require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class SlackContextTest < Minitest::Test
  SCRIPT = File.expand_path("../slack-context.rb", __dir__)

  def setup
    @directory = Dir.mktmpdir
    @bin = File.join(@directory, "bin")
    FileUtils.mkdir(@bin)
    @arguments = File.join(@directory, "arguments")
    @clipboard = File.join(@directory, "clipboard")
    write_fakes
    @env = {
      "PATH" => "#{@bin}:#{ENV.fetch("PATH")}",
      "SLACK_CONTEXT_TEST_ARGUMENTS" => @arguments,
      "SLACK_CONTEXT_TEST_CLIPBOARD" => @clipboard,
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
    _output, status = run_script

    assert_predicate status, :success?
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
    assert_includes output, "Usage: slack-context [SLACKDUMP_DUMP_ARGS...]"
    refute_path_exists @arguments
  end

  private

  def run_script(*arguments)
    Open3.capture2e(@env, "ruby", SCRIPT, *arguments, chdir: @directory)
  end

  def write_fakes
    write_executable("slackdump", <<~'SH')
      printf '%s\n' "$@" >"${SLACK_CONTEXT_TEST_ARGUMENTS:?}"
      [[ ${SLACK_CONTEXT_TEST_SLACKDUMP_FAIL-} != 1 ]] || exit 23
      [[ ${SLACK_CONTEXT_TEST_NO_ARCHIVE-} == 1 ]] || : >slackdump-test.zip
    SH

    write_executable("unzip", <<~'SH')
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
      printf '%s\n' "$@" >"${SLACK_CONTEXT_TEST_CLIPBOARD:?}"
    SH

    write_executable("clip", <<~'SH')
      printf 'https://example.slack.com/archives/clipboard\n'
    SH
  end

  def write_executable(name, body)
    path = File.join(@bin, name)
    File.write(path, "#!/usr/bin/env bash\n#{body}")
    FileUtils.chmod("u+x", path)
  end
end
