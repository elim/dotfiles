{
  config,
  lib,
  llm-agents,
  pkgs,
  ...
}:

let
  # Create wrapper that injects API key from sops
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    export OPENAI_API_KEY="$(cat ${config.sops.secrets."openai/api_key".path})"
    exec ${lib.getExe llm-agents.packages.${pkgs.system}.codex} "$@"
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
