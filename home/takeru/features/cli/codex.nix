{
  config,
  lib,
  llm-agents,
  pkgs,
  ...
}:

let
  gh = lib.getExe pkgs.github-cli;
  gpgconf = lib.getExe' pkgs.gnupg "gpgconf";
  codex = lib.getExe llm-agents.packages.${pkgs.system}.codex;

  # Resolve GitHub credentials before entering Codex's isolated runtime.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    resolve_ssh_auth_sock() {
      if [ -n "''${SSH_AUTH_SOCK:-}" ] && [ -S "''${SSH_AUTH_SOCK}" ]; then
        printf '%s\n' "$SSH_AUTH_SOCK"
        return 0
      fi

      agent_socket="$(${gpgconf} --list-dirs agent-ssh-socket 2>/dev/null || true)"
      if [ -n "$agent_socket" ] && [ -S "$agent_socket" ]; then
        printf '%s\n' "$agent_socket"
        return 0
      fi

      if [ -S "$HOME/.ssh/agent" ]; then
        printf '%s\n' "$HOME/.ssh/agent"
        return 0
      fi

      return 1
    }

    resolve_github_token() {
      if [ -n "''${GH_TOKEN:-}" ]; then
        printf '%s\n' "$GH_TOKEN"
        return 0
      fi

      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        printf '%s\n' "$GITHUB_TOKEN"
        return 0
      fi

      ${gh} auth token 2>/dev/null
    }

    export OPENAI_API_KEY="$(cat ${config.sops.secrets."openai/api_key".path})"

    if ssh_auth_sock="$(resolve_ssh_auth_sock)"; then
      export SSH_AUTH_SOCK="$ssh_auth_sock"
    fi

    if github_token="$(resolve_github_token)"; then
      export GH_TOKEN="$github_token"
      export GITHUB_TOKEN="$github_token"
    fi

    exec ${codex} "$@"
  '';
in
{
  # Use home-manager's codex module for configuration management
  programs.codex = {
    enable = true;
    package = codex-wrapper;
    # settings = { }; # Add config.toml settings here if needed
    # custom-instructions = ""; # Add custom guidance for agents here if needed
  };
}
