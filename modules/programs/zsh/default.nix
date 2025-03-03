{ config, pkgs, ... }:

{
  imports = [ ../shell ];

  home.packages = with pkgs; [
    zsh-completions
  ];

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

    plugins = [
      {
        name = "anyframe";
        src = pkgs.fetchFromGitHub {
          owner = "mollifier";
          repo = "anyframe";
          rev = "598675303044df8e9d04722f3adff4f63a238922";
          hash = "sha256-WaBaxxQzwpIlsfTgWGt8GSQin6nbm45mRvtW0VqociE=";
        };
      }
      {
        name = "cd-gitroot";
        src = pkgs.fetchFromGitHub {
          owner = "mollifier";
          repo = "cd-gitroot";
          rev = "66f6ba7549b9973eb57bfbc188e29d2f73bf31bb";
          hash = "sha256-pLdF8wbkA9mPI5cg8VPYAW7i3cWNJX3+lfAZ5cZPUgE=";
        };
      }
    ];
  };
}
