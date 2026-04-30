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
      "compose.override.yml"
      "docker-compose.override.yml"
      "plans/"
    ];

    includes = [
      { path = legacyConfig; }
    ];
  };
}
