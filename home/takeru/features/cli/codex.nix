{
  config,
  lib,
  llm-agents,
  mcp-servers-nix,
  pkgs,
  ...
}:

let
  gh = lib.getExe pkgs.github-cli;
  gpgconf = lib.getExe' pkgs.gnupg "gpgconf";
  codex = lib.getExe llm-agents.packages.${pkgs.system}.codex;
  esa-mcp = import ../development/esa-mcp-server-package.nix {
    inherit
      config
      lib
      pkgs
      mcp-servers-nix
      ;
  };

  # Resolve GitHub credentials before entering Codex's isolated runtime.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    use_no_alt_screen=1

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

    for arg in "$@"; do
      if [ "$arg" = "--no-alt-screen" ]; then
        use_no_alt_screen=0
        break
      fi
    done

    if [ "$use_no_alt_screen" -eq 1 ]; then
      set -- --no-alt-screen "$@"
    fi

    exec ${codex} \
      -c 'mcp_servers.esa.command="${lib.getExe esa-mcp}"' \
      "$@"
  '';
in
{
  # Use home-manager's codex module for configuration management
  programs.codex = {
    enable = true;
    package = codex-wrapper;
    # custom-instructions = ""; # Add custom guidance for agents here if needed
  };
}
