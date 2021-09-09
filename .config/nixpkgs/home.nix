{ config, pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts
    (dicts: with dicts; [ en en-computers en-science ]);
  unstable = import <nixpkgs-unstable> {};
in {
  home.packages = with pkgs; [
    albert
    aspell
    dash
    docker-compose
    emacs
    htop
    keychain
    nkf
    peco
    pgformatter
    ripgrep
    shellcheck
    stern
    thunderbird
    xkeysnail
    xorg.xhost
    xsel

    unstable._1password
    unstable._1password-gui
    unstable.azure-cli
    unstable.brave
    unstable.ghq
    unstable.github-cli
    unstable.slack
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      git_commit =  {
        tag_disabled = false;
      };

      time = {
        disabled = false;
        format = "%T";
      };
    };
  };
}
