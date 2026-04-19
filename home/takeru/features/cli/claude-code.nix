{
  config,
  llm-agents,
  pkgs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.claude-code = {
    enable = true;
    package = llm-agents.packages.${system}.claude-code;
    settings = {
      apiKeyHelper = "cat ${config.sops.secrets."claude/api_key".path}";
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
