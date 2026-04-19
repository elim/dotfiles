{
  llm-agents,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Gemini CLI - Google's terminal AI agent
  # Uses OAuth2.0 authentication (no API key required)
  # Login via: gemini login
  home.packages = [
    llm-agents.packages.${system}.gemini-cli
  ];
}
