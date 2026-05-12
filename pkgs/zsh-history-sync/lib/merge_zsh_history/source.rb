# frozen_string_literal: true

module MergeZshHistory
  class Source < Struct.new(:kind, :label, :path, :remote, keyword_init: true)
    def ssh?
      kind == :ssh
    end
  end
end
