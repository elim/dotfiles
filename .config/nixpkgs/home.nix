{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};

  aspell = pkgs.aspellWithDicts
    (dicts: with dicts; [ en en-computers en-science ]);
  emacs = pkgs.emacsNativeComp;
in {
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "94df7ad97b2920fcf52d361c8d8e8a1ce5697c81";
    }))
  ];

  home.packages = with pkgs; [
    albert
    aspell
    atomicparsley
    colordiff
    dash
    docker-compose
    emacs
    file
    firefox
    gimp
    gnomeExtensions.appindicator
    htop
    imagemagick
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
    skktools
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

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

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
