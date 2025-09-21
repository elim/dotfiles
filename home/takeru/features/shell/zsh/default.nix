{
  config,
  lib,
  pkgs,
  ...
}:

let
  symlink = config.lib.file.mkOutOfStoreSymlink;
  shellAliases = import ../aliases.nix { inherit pkgs; };
  dotDir = config.xdg.configHome + "/zsh";

  chpwd_ls =
    let
      lsCommand = shellAliases.ls;
    in
    builtins.readFile (
      pkgs.replaceVars ./chpwd.zsh.in {
        ls = lsCommand;
      }
    );
in
{
  home.packages = with pkgs; [
    zsh-completions
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;

    inherit dotDir;

    inherit shellAliases;

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

    initContent = builtins.concatStringsSep "\n" [
      (builtins.readFile ./zshrc.legacy)
      (builtins.readFile ./snippets/tmux)
      "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      "source ${dotDir}/.p10k.zsh"
      chpwd_ls
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
      {
        name = "clipboard";
        src = pkgs.fetchFromGitHub {
          owner = "zpm-zsh";
          repo = "clipboard";
          rev = "c3a4a054cefe313d853dc9c32debb1b18aa7513c";
          hash = "sha256-XtS5HQ2HFYBoBZikuI82XT4MDcXsaPJioI7zNyBoIhs=";
        };
      }
    ];
  };

  home.file = {
    "${dotDir}/.p10k.zsh" = {
      source = symlink "${config.home.homeDirectory}/dotfiles/home/${config.home.username}/features/shell/zsh/.p10k.zsh";
    };
  };
}
