{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
      apiKeyHelper = "cat ${config.sops.secrets."claude/api_key".path}";
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
