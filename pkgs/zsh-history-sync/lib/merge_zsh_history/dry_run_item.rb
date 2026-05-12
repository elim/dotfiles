# frozen_string_literal: true

module MergeZshHistory
  DryRunItem = Struct.new(:entry, :reasons, keyword_init: true)
end
