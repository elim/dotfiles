{
  config,
  llm-agents,
  pkgs,
  ...
}:

{
  programs.claude-code = {
    enable = true;
    package = llm-agents.packages.${pkgs.system}.claude-code;
    settings = {
      apiKeyHelper = "cat ${config.sops.secrets."claude/api_key".path}";
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
