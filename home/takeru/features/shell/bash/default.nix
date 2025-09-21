{
  config,
  lib,
  pkgs,
  ...
}:

let
  shellAliases = import ../aliases.nix { inherit config lib pkgs; };

  bashrcLegacy = pkgs.writeTextFile {
    name = "bashrc-legacy";
    text = builtins.readFile ./bashrc.legacy;
  };
in
{
  programs.bash = {
    enable = true;

    inherit shellAliases;

    bashrcExtra = ''
      source ${bashrcLegacy}
    '';

    initExtra = ''
      # Enable incremental search through command history.
      stty stop undef
    '';
  };
}
