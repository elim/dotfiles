# -*- mode: sh; sh-shell: zsh; -*-

# Wrap coding agent CLIs with tmux-local key suppression.
# This keeps accidental C-c/C-g/C-l from reaching the agent UI and
# preserves the existing C-b workaround for Claude Code.
# Reference: https://github.com/anthropics/claude-code/issues/22315
typeset -g AGENT_TMUX_GUARD_PANE_ID=""

agent_tmux_guard_bind() {
  emulate -L zsh

  local key
  local target_pane_id pane_condition
  local -a blocked_keys=(C-g C-l)

  [[ -n "$TMUX" ]] || return 0

  target_pane_id="${1:-$AGENT_TMUX_GUARD_PANE_ID}"
  [[ -n "$target_pane_id" ]] || return 0

  AGENT_TMUX_GUARD_PANE_ID="$target_pane_id"
  pane_condition="#{==:#{pane_id},${target_pane_id}}"

  tmux bind -n C-b if-shell -F "$pane_condition" "send-keys Left" "send-keys C-b" 2>/dev/null
  tmux bind -n M-g if-shell -F "$pane_condition" "send-keys C-g" "send-keys M-g" 2>/dev/null

  # C-c acts as a passthrough prefix (Emacs C-c style): shows a prompt and enters a
  # one-shot key table. C-c C-c = cancel, C-c C-l = clear screen, C-c C-g = open editor.
  # Outside the agent pane C-c is forwarded normally.
  tmux bind -n C-c if-shell -F "$pane_condition" \
    "{ display-message 'C-c — [c]cancel [l]clear [g]editor  Esc=back' ; switch-client -T agent-passthrough-cc }" \
    "send-keys C-c" 2>/dev/null
  tmux bind -T agent-passthrough-cc C-c "send-keys C-c" 2>/dev/null
  tmux bind -T agent-passthrough-cc C-g "send-keys C-g" 2>/dev/null
  tmux bind -T agent-passthrough-cc C-l "send-keys C-l" 2>/dev/null
  tmux bind -T agent-passthrough-cc Escape "display-message ''" 2>/dev/null

  for key in $blocked_keys; do
    tmux bind -n "$key" if-shell -F "$pane_condition" "display-message '$key blocked; use C-c $key to pass through'" "send-keys $key" 2>/dev/null
  done
}

agent_tmux_guard_unbind() {
  emulate -L zsh

  local key
  local -a guarded_keys=(C-b C-c C-g C-l M-g)
  local -a passthrough_keys=(C-c C-g C-l Escape)

  [[ -n "$TMUX" ]] || return 0

  for key in $guarded_keys; do
    tmux unbind -n "$key" 2>/dev/null
  done

  for key in $passthrough_keys; do
    tmux unbind -T agent-passthrough-cc "$key" 2>/dev/null
  done
}

agent_tmux_guard_precmd() {
  [[ -n "$AGENT_TMUX_GUARD_PANE_ID" ]] || return 0
  agent_tmux_guard_unbind
}

agent_tmux_guard_preexec() {
  emulate -L zsh

  local command_line="$1"

  [[ -n "$AGENT_TMUX_GUARD_PANE_ID" ]] || return 0

  case "$command_line" in
    fg|fg\ *)
      if jobs -s >/dev/null 2>&1; then
        agent_tmux_guard_bind
      else
        AGENT_TMUX_GUARD_PANE_ID=""
      fi
      ;;
    claude\ *|claude|codex\ *|codex)
      ;;
    *)
      AGENT_TMUX_GUARD_PANE_ID=""
      ;;
  esac
}

run_agent_with_tmux_guard() {
  emulate -L zsh

  if [[ -n "$TMUX" ]]; then
    AGENT_TMUX_GUARD_PANE_ID="$(tmux display-message -p '#{pane_id}')"
    agent_tmux_guard_bind "$AGENT_TMUX_GUARD_PANE_ID"
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
