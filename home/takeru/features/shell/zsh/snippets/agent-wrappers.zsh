# -*- mode: sh; sh-shell: zsh; -*-

# Wrap coding agent CLIs with tmux-local key suppression.
# Guard bindings live in agent-guard.conf and are loaded at tmux startup.
# They evaluate #{@agent_guard_pane} at key-press time, so this file only
# manages the lifecycle of that session option.
# Reference: https://github.com/anthropics/claude-code/issues/22315
typeset -g AGENT_TMUX_GUARD_PANE_ID=""

agent_tmux_guard_activate() {
  emulate -L zsh

  local target_pane_id

  [[ -n "$TMUX" ]] || return 0

  target_pane_id="${1:-$AGENT_TMUX_GUARD_PANE_ID}"
  [[ -n "$target_pane_id" ]] || return 0

  AGENT_TMUX_GUARD_PANE_ID="$target_pane_id"
  tmux set @agent_guard_pane "$target_pane_id" 2>/dev/null
  tmux set display-time 0 2>/dev/null
}

agent_tmux_guard_deactivate() {
  emulate -L zsh

  [[ -n "$TMUX" ]] || return 0

  # Unset the option so bindings fall through to normal behaviour.
  # AGENT_TMUX_GUARD_PANE_ID is intentionally preserved so that `fg` can
  # re-activate the guard for the same pane without re-querying tmux.
  tmux set -u @agent_guard_pane 2>/dev/null
  tmux set -u display-time 2>/dev/null
}

agent_tmux_guard_precmd() {
  [[ -n "$AGENT_TMUX_GUARD_PANE_ID" ]] || return 0
  agent_tmux_guard_deactivate
}

agent_tmux_guard_preexec() {
  emulate -L zsh

  local command_line="$1"

  [[ -n "$AGENT_TMUX_GUARD_PANE_ID" ]] || return 0

  case "$command_line" in
    fg|fg\ *)
      if jobs -s >/dev/null 2>&1; then
        agent_tmux_guard_activate
      else
        AGENT_TMUX_GUARD_PANE_ID=""
        agent_tmux_guard_deactivate
      fi
      ;;
    claude\ *|claude|codex\ *|codex)
      ;;
    *)
      AGENT_TMUX_GUARD_PANE_ID=""
      agent_tmux_guard_deactivate
      ;;
  esac
}

run_agent_with_tmux_guard() {
  emulate -L zsh

  if [[ -n "$TMUX" ]]; then
    agent_tmux_guard_activate "$(tmux display-message -p '#{pane_id}')"
  fi

  "$@"
}

add-zsh-hook precmd agent_tmux_guard_precmd
add-zsh-hook preexec agent_tmux_guard_preexec

claude() {
  run_agent_with_tmux_guard command claude "$@"
}

codex() {
  run_agent_with_tmux_guard command codex "$@"
}
