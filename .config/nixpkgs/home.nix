{ config, pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts
    (dicts: with dicts; [ en en-computers en-science ]);
  unstable = import <nixpkgs-unstable> {};
in {
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/bdc2b79671bf70cf73efa3ee2320bd414087315a.tar.gz;
    }))
  ];

  home.packages = with pkgs; [
    albert
    aspell
    colordiff
    dash
    docker-compose
    emacsGcc
    file
    gimp
    gnomeExtensions.appindicator
    htop
    k9s
    keychain
    kubectl
    libreoffice
    mpv
    nkf
    peco
    pgformatter
    ripgrep
    shellcheck
    stern
    thunderbird
    tmux
    unzip
    xkeysnail
    xorg.xhost
    xsel
  ] ++ (with unstable; [
    _1password
    _1password-gui
    azure-cli
    brave
    ghq
    github-cli
    slack
    zoom-us
  ]);

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
