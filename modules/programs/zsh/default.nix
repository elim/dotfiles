{ config, pkgs, ... }:

let
  zshenvLegacy = pkgs.writeTextFile {
    name = "zshenv-legacy";
    text = builtins.readFile ./zshenv.legacy;
  };

  zshrcLegacy = pkgs.writeTextFile {
    name = "zshrc-legacy";
    text = builtins.readFile ./zshrc.legacy;
  };
in
{
  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    shellGlobalAliases = {
      G = "| grep";
      H = "| head";
      L = "| less";
      S = "| sed";
      T = "| tail";
      W = "| wc";
    };

    envExtra = ''
      source ${zshenvLegacy}
    '';

    initExtra = ''
      source ${zshrcLegacy}
    '';
  };
}
