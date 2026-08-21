{ config, pkgs, ... }:

let
  legacyConfig = pkgs.writeTextFile {
    name = "config.legacy";
    text = builtins.readFile ./config.legacy;
  };
in
{
  programs.git = {
    enable = true;

    ignores = [
      "*~"
      ".DS_Store"
      ".direnv"
      "compose.override.yml"
      "docker-compose.override.yml"

      # Keep local coding-agent instructions out of commits by default.
      "**/.claude/settings.local.json"
      ".agents/rules/"
      "AGENTS.md"
      "AGENTS.override.md"
      "CLAUDE.md"
      "CLAUDE.local.md"
      "GEMINI.md"

      "plans/"
    ];

    includes = [
      { path = legacyConfig; }
      {
        condition = "hasconfig:remote.*.url:keybase://**";
        path = ./config.keybase;
      }
    ];
  };
}
