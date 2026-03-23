{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
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

  claudeWrapper = builtins.readFile ./snippets/claude-wrapper.zsh.in;

  tmuxLaunchWithNixEnv = pkgs.writeShellScriptBin "tmux-launch-with-nix-env" (
    builtins.readFile ./snippets/tmux-launch-with-nix-env.sh.in
  );

  darwinNixSetup =
    if pkgs.stdenv.isDarwin then
      ''
        # macOS用のNixデーモン設定を読み込む
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      ''
    else
      "";
in
{
  home.packages = with pkgs; [
    zsh-completions
    zsh-powerlevel10k
    tmuxLaunchWithNixEnv
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
      darwinNixSetup
      (builtins.readFile ./zshrc.legacy)
      (builtins.readFile ./snippets/tmux)
      "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      "source ${dotDir}/.p10k.zsh"
      chpwd_ls
      claudeWrapper
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
    # --- Powerlevel10k Configuration ---
    # How to update this configuration:
    # 1. Run the following command in your terminal to generate a new
    #    configuration interactively:
    #    $ POWERLEVEL9K_CONFIG_FILE=/tmp/p10k.zsh p10k configure
    #
    # 2. Copy the content of the generated /tmp/p10k.zsh and paste it
    #    into the source file declared above, then commit the change.
    #    Path: ./home/${config.home.username}/programs/zsh/.p10k.zsh
    "${dotDir}/.p10k.zsh" = {
      source = "${dotfiles}/home/${config.home.username}/features/shell/zsh/.p10k.zsh";
    };
  };
}
