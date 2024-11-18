{ config, pkgs, ... }:

let
  bashrcLegacy = pkgs.writeTextFile {
    name = "bashrc-legacy";
    text = builtins.readFile ./bashrc.legacy;
  };
in
{
  programs.bash = {
    enable = true;

    bashrcExtra = ''
      source ${bashrcLegacy}
    '';

    initExtra = ''
      # Enable incremental search through command history.
      stty stop undef
    '';
  };
}
