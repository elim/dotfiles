{ config, pkgs, ... }:

let
  bashrcLegacy = pkgs.writeTextFile {
    name = "bashrc-legacy";
    text = builtins.readFile ./bashrc.legacy;
  };
in
{
  imports = [ ../shell ];

  programs.bash = {
    enable = true;

    shellAliases = config.shell.aliases;

    bashrcExtra = ''
      source ${bashrcLegacy}
    '';

    initExtra = ''
      # Enable incremental search through command history.
      stty stop undef
    '';
  };
}
