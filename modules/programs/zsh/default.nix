{
  config,
  lib,
  pkgs,
  ...
}:

let
  symlink = config.lib.file.mkOutOfStoreSymlink;
  dotDir = ".config/zsh";
  zdotdir = "$HOME/" + lib.escapeShellArg dotDir;
in
{

  imports = [ ../shell ];

  home.packages = with pkgs; [
    zsh-completions
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;

    dotDir = dotDir;

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

    initExtra = builtins.concatStringsSep "\n" [
      (builtins.readFile ./zshrc.legacy)
      (builtins.readFile ./snippets/tmux)
      (builtins.readFile ./snippets/keychain)
      "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      "source ${zdotdir}/.p10k.zsh"
    ];

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

  home.file = {
    "${dotDir}/.p10k.zsh" = {
      source = symlink "${config.home.homeDirectory}/dotfiles/modules/programs/zsh/.p10k.zsh";
    };
  };
}
