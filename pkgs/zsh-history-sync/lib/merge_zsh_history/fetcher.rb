# frozen_string_literal: true

require "fileutils"
require "open3"

module MergeZshHistory
  class Fetcher
    def fetch(sources, workspace:)
      sources.each_with_index.map do |source, index|
        destination = File.join(workspace, format("%02d.zsh_history", index))

        source.ssh? ? fetch_ssh(source, destination) : fetch_local(source, destination)

        FetchedSource.new(source: source, path: destination)
      end
    end

    private

    def fetch_local(source, destination)
      raise Error, "local history file not found: #{source.path}" unless File.file?(source.path)

      FileUtils.cp(source.path, destination)
    end

    def fetch_ssh(source, destination)
      run!("scp", "-q", "#{source.remote}:#{source.path}", destination)
    rescue Error => e
      raise Error, "failed to fetch #{source.label}: #{e.message}"
    end

    def run!(*command)
      _stdout, stderr, status = Open3.capture3(*command)
      return if status.success?

      message = stderr.strip
      raise Error, message.empty? ? "command failed: #{command.join(' ')}" : message
    end
  end
end
