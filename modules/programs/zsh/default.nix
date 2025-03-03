{ config, pkgs, ... }:

{
  imports = [ ../shell ];

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";

    shellAliases = config.shell.aliases;

    shellGlobalAliases = {
      G = "| grep";
      H = "| head";
      L = "| less";
      S = "| sed";
      T = "| tail";
      W = "| wc";
    };

    syntaxHighlighting = {
      enable = true;
    };

    envExtra = builtins.readFile ./zshenv.legacy;

    initExtra =
      builtins.readFile ./zshrc.legacy
      + builtins.readFile ./snippets/tmux
      + builtins.readFile ./snippets/keychain;
  };
}
