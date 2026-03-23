# -*- mode: sh; sh-shell: zsh; -*-

# Wrap claude command to use synchronous emacsclient as EDITOR
# This allows C-g in Claude Code to open Emacs with full keybindings
# Also works around C-b bug in Claude Code when running in tmux
# Reference: https://github.com/anthropics/claude-code/issues/22315
claude() {
  # Check if running inside tmux
  if [[ -n "$TMUX" ]]; then
    # Bind C-b to Left arrow key as workaround for Claude Code bug
    tmux bind -n C-b send-keys Left 2>/dev/null

    # Setup trap to unbind when function exits (both normal and abnormal)
    trap 'tmux unbind -n C-b 2>/dev/null' EXIT INT TERM
  fi

  command claude "$@"
}
