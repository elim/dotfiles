require "English"
require "io/console"
require "json"
require "pathname"
require "tempfile"

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

    def self.load(path, user_map:, conversation_map:)
      payload = JSON.parse(File.read(path))
      return unless payload.is_a?(Hash)

      messages = payload["messages"]
      return unless messages.is_a?(Array)

      message = messages.first
      return unless message.is_a?(Hash)

      new(
        channel_id: payload["channel_id"],
        channel_name: payload["name"],
        author_id: message["user"],
        text: message["text"],
        path: path,
        user_map: user_map,
        conversation_map: conversation_map,
      )
    rescue JSON::ParserError, SystemCallError
      nil
    end

    def initialize(channel_id:, channel_name:, author_id:, text:, path:, user_map:, conversation_map:)
      @channel_id = channel_id
      @channel_name = channel_name
      @author_id = author_id
      @text = text
      @path = path
      @user_map = user_map
      @conversation_map = conversation_map
    end

    def lines
      [channel_line, author_line, excerpt_line, "JSON: #{@path}"].compact
    end

    private

    def channel_line
      description = @conversation_map.describe(@channel_id, fallback_name: @channel_name)
      return description if description

      return if blank?(@channel_id) && blank?(@channel_name)
      return "Channel: ##{@channel_name} (#{@channel_id})" unless blank?(@channel_name) || blank?(@channel_id)
      return "Channel: ##{@channel_name}" unless blank?(@channel_name)

      "Channel: #{@channel_id}"
    end

    def excerpt_line
      return if blank?(@text)

      normalized = @user_map.resolve_mentions(@text).gsub(/[[:space:]]+/, " ").strip
      excerpt = normalized.each_char.take(EXCERPT_LENGTH).join
      excerpt += "…" if normalized.length > EXCERPT_LENGTH
      "First message: #{excerpt}"
    end

    def author_line
      return if blank?(@author_id)

      name = @user_map.resolve(@author_id)
      name ? "Author: #{name} (#{@author_id})" : "Author: #{@author_id}"
    end

    def blank?(value)
      !value.is_a?(String) || value.empty?
    end
  end

  class SummaryPresenter
    def initialize(output:, user_map: UserMap.empty, conversation_map: ConversationMap.empty)
      @output = output
      @user_map = user_map
      @conversation_map = conversation_map
    end

    def present(paths)
      paths.filter_map do |path|
        ConversationSummary.load(path, user_map: @user_map, conversation_map: @conversation_map)
      end.each do |summary|
        @output.puts "Fetched context:"
        summary.lines.each { |line| @output.puts line }
      end
    end
  end


  class UserMap
    USER_MENTION = /<@((?:U|W)[A-Z0-9]{8,})>/

    attr_reader :path

    def self.empty
      new(nil)
    end

    def initialize(path)
      @path = path
      @records = load_records
    end

    def resolve(user_id)
      record = @records[user_id]
      return record if record.is_a?(String) && !record.empty?
      return unless record.is_a?(Hash)

      %w[best_name display_name full_name username].filter_map { |key| record[key] }.find do |name|
        name.is_a?(String) && !name.empty?
      end
    end

    def resolve_mentions(text)
      text.gsub(USER_MENTION) do |mention|
        name = resolve(Regexp.last_match(1))
        name ? "@#{name}" : mention
      end
    end

    def update_from(paths)
      raise Error, "slack-context: user map path is required to update users" unless @path

      discovered = UserRecordExtractor.new.extract(paths)
      updated_records = @records.transform_values { |record| record.is_a?(Hash) ? record.dup : record }
      discovered.each do |user_id, record|
        existing = updated_records[user_id]
        updated_records[user_id] = existing.is_a?(Hash) ? existing.merge(record) : record
      end
      write_records(updated_records)
      @records = updated_records
      discovered.length
    end

    private

    def load_records
      return {} unless @path&.file?

      payload = JSON.parse(@path.read)
      raise Error, "slack-context: #{@path} must contain a JSON object" unless payload.is_a?(Hash)

      payload
    rescue JSON::ParserError => e
      raise Error, "slack-context: could not parse #{@path}: #{e.message}"
    rescue SystemCallError => e
      raise Error, "slack-context: could not read #{@path}: #{e.message}"
    end

    def write_records(records)
      @path.dirname.mkpath
      Tempfile.create(["users", ".json"], @path.dirname.to_s) do |file|
        file.write(JSON.pretty_generate(records.sort.to_h))
        file.write("\n")
        file.flush
        file.fsync
        File.rename(file.path, @path)
      end
    rescue SystemCallError => e
      raise Error, "slack-context: could not write #{@path}: #{e.message}"
    end
  end

  class UserRecordExtractor
    USER_ID = /\A(?:U|W)[A-Z0-9]{8,}\z/

    def extract(paths)
      records = {}
      paths.each do |path|
        payload = JSON.parse(File.read(path))
        collect(payload, records)
      rescue JSON::ParserError, SystemCallError
        next
      end
      records
    end

    private

    def collect(value, records)
      case value
      when Array
        value.each { |item| collect(item, records) }
      when Hash
        collect_record(value, records)
        collect_attachment_author(value, records)
        value.each_value { |nested| collect(nested, records) }
      end
    end

    def collect_record(value, records)
      user_id = value["id"] || value["user"]
      return unless user_id.is_a?(String) && USER_ID.match?(user_id)

      profile = if value["user_profile"].is_a?(Hash)
                  value["user_profile"]
                elsif value["profile"].is_a?(Hash)
                  value["profile"]
                else
                  value
                end
      record = build_record(value, profile)
      merge_record(records, user_id, record) if record["best_name"]
    end

    def collect_attachment_author(value, records)
      user_id = value["author_id"]
      return unless user_id.is_a?(String) && USER_ID.match?(user_id)

      name = clean(value["author_name"] || value["author_subname"])
      return unless name

      merge_record(
        records,
        user_id,
        compact_record(
          "best_name" => name,
          "display_name" => clean(value["author_name"]),
          "full_name" => clean(value["author_subname"] || value["author_name"]),
          "source" => "dump-attachment",
        ),
      )
    end

    def build_record(value, profile)
      display_name = clean(profile["display_name"] || profile["display_name_normalized"])
      full_name = clean(profile["real_name"] || profile["real_name_normalized"] || value["real_name"])
      username = clean(value["name"] || value["username"] || profile["name"])
      best_name = [display_name, full_name, username].compact.first

      compact_record(
        "best_name" => best_name,
        "display_name" => display_name,
        "full_name" => full_name,
        "username" => username,
        "source" => "dump-embedded",
      )
    end

    def compact_record(record)
      record.compact.reject { |_key, value| value.respond_to?(:empty?) && value.empty? }
    end

    def merge_record(records, user_id, record)
      records[user_id] = records.fetch(user_id, {}).merge(record)
    end

    def clean(value)
      return unless value

      text = value.to_s.gsub(/[\t\r\n]/, " ").strip
      text unless text.empty?
    end
  end

  class ConversationMap
    attr_reader :path

    def self.empty
      new(nil, user_map: UserMap.empty)
    end

    def initialize(path, user_map:)
      @path = path
      @user_map = user_map
      @records = load_records
    end

    def describe(conversation_id, fallback_name: nil)
      return unless conversation_id.is_a?(String) && !conversation_id.empty?

      record = @records[conversation_id]
      return inferred_description(conversation_id, fallback_name) unless record.is_a?(Hash)

      case record["type"]
      when "im"
        prefix = record["is_ext_shared"] ? "Slack Connect DM" : "DM"
        name = @user_map.resolve(record["user_id"]) || record["display_name"] || record["user_id"]
        name ? "#{prefix}: #{name} (#{conversation_id})" : "#{prefix}: #{conversation_id}"
      when "mpim"
        "Group DM: #{conversation_id}"
      else
        channel_name = record["name"] || fallback_name
        channel_name && !channel_name.empty? ? "Channel: ##{channel_name} (#{conversation_id})" : "Channel: #{conversation_id}"
      end
    end

    def replace(channels)
      raise Error, "slack-context: conversation map path is required to update conversations" unless @path

      records = channels.filter_map { |channel| record_from(channel) }.sort.to_h
      write_records(records)
      @records = records
      records.length
    end

    private

    def inferred_description(conversation_id, fallback_name)
      return "DM: #{conversation_id}" if conversation_id.start_with?("D")
      return "Group DM: #{conversation_id}" if fallback_name&.start_with?("mpdm-")

      nil
    end

    def record_from(channel)
      return unless channel.is_a?(Hash)

      conversation_id = channel["id"] || channel["channel_id"]
      return unless conversation_id.is_a?(String) && !conversation_id.empty?

      type = if channel["is_im"]
               "im"
             elsif channel["is_mpim"] || channel["name"]&.start_with?("mpdm-")
               "mpim"
             else
               "channel"
             end
      record = {
        "type" => type,
        "name" => present(channel["name"]),
        "user_id" => present(channel["user"]),
        "is_ext_shared" => !!channel["is_ext_shared"],
      }.compact
      record["display_name"] = @user_map.resolve(record["user_id"]) if record["user_id"]
      [conversation_id, record.compact]
    end

    def present(value)
      value if value.is_a?(String) && !value.empty?
    end

    def load_records
      return {} unless @path&.file?

      payload = JSON.parse(@path.read)
      raise Error, "slack-context: #{@path} must contain a JSON object" unless payload.is_a?(Hash)

      payload
    rescue JSON::ParserError => e
      raise Error, "slack-context: could not parse #{@path}: #{e.message}"
    rescue SystemCallError => e
      raise Error, "slack-context: could not read #{@path}: #{e.message}"
    end

    def write_records(records)
      @path.dirname.mkpath
      Tempfile.create(["conversations", ".json"], @path.dirname.to_s) do |file|
        file.write(JSON.pretty_generate(records))
        file.write("\n")
        file.flush
        file.fsync
        File.rename(file.path, @path)
      end
    rescue SystemCallError => e
      raise Error, "slack-context: could not write #{@path}: #{e.message}"
    end
  end

  class ConversationCatalogUpdater
    def initialize(runner:)
      @runner = runner
    end

    def update(conversation_map)
      output = @runner.capture("slackdump", "list", "channels", "-format", "JSON", "-no-json")
      payload = JSON.parse(output)
      channels = payload.is_a?(Array) ? payload : payload["channels"]
      raise Error, "slack-context: slackdump channel list did not contain an array" unless channels.is_a?(Array)

      conversation_map.replace(channels)
    rescue JSON::ParserError => e
      raise Error, "slack-context: could not parse slackdump channel list: #{e.message}"
    end
  end

  class WorkspaceConfig
    FILE_NAME = ".slack-context.json"

    def self.user_map_path(cwd:, explicit_path: nil, create: false)
      data_file_path(
        cwd: cwd,
        explicit_path: explicit_path,
        create: create,
        config_key: "users_file",
        default_name: "users.json",
      )
    end

    def self.conversation_map_path(cwd:, explicit_path: nil, create: false)
      data_file_path(
        cwd: cwd,
        explicit_path: explicit_path,
        create: create,
        config_key: "conversations_file",
        default_name: "conversations.json",
      )
    end

    def self.find_config(start_directory)
      directory = File.expand_path(start_directory)

      loop do
        candidate = File.join(directory, FILE_NAME)
        return candidate if File.file?(candidate)

        parent = File.dirname(directory)
        return if parent == directory

        directory = parent
      end
    end
    private_class_method :find_config

    def self.data_file_path(cwd:, explicit_path:, create:, config_key:, default_name:)
      return File.expand_path(explicit_path, cwd) if explicit_path

      config_path = find_config(cwd)
      return configured_file(config_path, config_key, default_name, create) if config_path

      data_file = File.join(cwd, default_name)
      data_file if create || File.file?(data_file)
    end
    private_class_method :data_file_path

    def self.configured_file(config_path, config_key, default_name, create)
      config = JSON.parse(File.read(config_path))
      configured = config[config_key]
      configured = default_name if create && (!configured.is_a?(String) || configured.empty?)
      return unless configured.is_a?(String) && !configured.empty?

      File.expand_path(configured, File.dirname(config_path))
    rescue JSON::ParserError => e
      raise Error, "slack-context: could not parse #{config_path}: #{e.message}"
    rescue SystemCallError => e
      raise Error, "slack-context: could not read #{config_path}: #{e.message}"
    end
    private_class_method :configured_file
  end

  class Fetcher
    ARCHIVE_PATTERN = "slackdump*.zip"

    def initialize(runner:, error_output:, summary_presenter:, user_map:, update_users: false)
      @runner = runner
      @error_output = error_output
      @summary_presenter = summary_presenter
      @user_map = user_map
      @update_users = update_users
    end

    def fetch(arguments)
      archive = dump(arguments)
      paths = extract(archive)
      update_users(paths) if @update_users
      @runner.run("cpath", *paths)

      @summary_presenter.present(paths)
      @error_output.puts "Copied to clipboard:"
      paths.each { |path| @error_output.puts path }
    ensure
      remove_archive(archive) if archive
    end

    private

    def update_users(paths)
      count = @user_map.update_from(paths)
      @error_output.puts "Updated user map: #{@user_map.path} (#{count} records from dump)"
    end

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
             slack-context [--users-file PATH] [SLACKDUMP_DUMP_ARGS...]
             slack-context --update-users-from-dump [SLACKDUMP_DUMP_ARGS...]
             slack-context --update-conversations [SLACKDUMP_DUMP_ARGS...]

      Dump Slack content with slackdump, extract the archive, and copy the
      extracted JSON path(s) to the clipboard.

      With --interactive, press r or Enter to fetch again, or q or Ctrl-C
      to quit.

      Resolve message authors and mentions with users.json found through
      .slack-context.json, in the current directory, or at --users-file.
      With --update-users-from-dump, create or update that map using only
      user profiles embedded in the downloaded archive.
      With --update-conversations, refresh conversations.json with channel,
      DM, MPDM, and Slack Connect metadata from slackdump.
      Use -- before slackdump arguments that match slack-context options.

      Examples:
        slack-context
        slack-context -time-from 2026-07-03 -time-to 2026-07-04 "$(clip)"
        slack-context -files=false https://example.slack.com/archives/...
        slack-context --interactive https://example.slack.com/archives/...
        slack-context --users-file ./users.json https://example.slack.com/archives/...
        slack-context --update-users-from-dump https://example.slack.com/archives/...
    USAGE

    def initialize(arguments, input: $stdin, error_output: $stderr, runner: CommandRunner.new)
      @arguments = arguments.dup
      @input = input
      @error_output = error_output
      @runner = runner
    end

    def run
      options = parse_options

      return show_help if help?
      return fail_with("slack-context: --interactive requires a terminal on stdin") if options[:interactive] && !@input.tty?

      user_map_path = WorkspaceConfig.user_map_path(
        cwd: Dir.pwd,
        explicit_path: options[:users_file],
        create: options[:update_users],
      )
      user_map = UserMap.new(user_map_path && Pathname(user_map_path))
      conversation_map_path = WorkspaceConfig.conversation_map_path(
        cwd: Dir.pwd,
        explicit_path: options[:conversations_file],
        create: options[:update_conversations],
      )
      conversation_map = ConversationMap.new(conversation_map_path && Pathname(conversation_map_path), user_map: user_map)
      if options[:update_conversations]
        count = ConversationCatalogUpdater.new(runner: @runner).update(conversation_map)
        @error_output.puts "Updated conversation map: #{conversation_map.path} (#{count} conversations)"
      end
      @fetcher = Fetcher.new(
        runner: @runner,
        error_output: @error_output,
        summary_presenter: SummaryPresenter.new(
          output: @error_output,
          user_map: user_map,
          conversation_map: conversation_map,
        ),
        user_map: user_map,
        update_users: options[:update_users],
      )
      sources = @arguments.empty? ? [clipboard] : @arguments
      options[:interactive] ? run_interactively(sources) : fetch_once(sources)
    rescue Error => e
      report(e)
      e.status
    end

    private

    def parse_options
      options = {
        interactive: false,
        users_file: nil,
        update_users: false,
        conversations_file: nil,
        update_conversations: false,
      }
      dump_arguments = []

      until @arguments.empty?
        argument = @arguments.shift
        case argument
        when "--"
          dump_arguments.concat(@arguments)
          @arguments.clear
        when "--interactive"
          options[:interactive] = true
        when "--users-file"
          raise Error, "slack-context: --users-file requires a path" if @arguments.empty?

          options[:users_file] = @arguments.shift
        when /\A--users-file=(.+)\z/
          options[:users_file] = Regexp.last_match(1)
        when "--update-users-from-dump"
          options[:update_users] = true
        when "--conversations-file"
          raise Error, "slack-context: --conversations-file requires a path" if @arguments.empty?

          options[:conversations_file] = @arguments.shift
        when /\A--conversations-file=(.+)\z/
          options[:conversations_file] = Regexp.last_match(1)
        when "--update-conversations"
          options[:update_conversations] = true
        else
          dump_arguments << argument
        end
      end

      @arguments = dump_arguments
      options
    end

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
