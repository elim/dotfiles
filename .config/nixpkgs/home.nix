{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> { };

  aspell = pkgs.aspellWithDicts
    (dicts: with dicts; [ en en-computers en-science ]);
  emacs = pkgs.emacsUnstable;
  handbrake = pkgs.handbrake.override { useFdk = true; };
in
{
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "e6b5351ef8059316e5114626f473dd15994318db";
    }))
  ];

  home = rec {
    stateVersion = "22.11";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  home.packages = with pkgs; [
    albert
    aspell
    atomicparsley
    colordiff
    dash
    delta
    docker-compose
    emacs
    exiftool
    fd
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
    nkf
    nodePackages.sql-formatter
    peco
    pgformatter
    ripgrep
    shellcheck
    skktools
    stern
    tmux
    unzip
    xkeysnail
    xorg.xhost
    xsel
  ] ++ (with unstable; [
    avidemux
    azure-cli
    brave
    ffmpeg
    ghq
    github-cli
    handbrake
    kubelogin
    mpv
    nixpkgs-fmt
    slack
    thunderbird
    unar
    zoom-us
  ]);

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.sessionVariables.GTK_THEME = "palenight";

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "${config.gtk.theme.name}";
        cursor-size = 96;
        cursor-theme = "${config.gtk.cursorTheme.name}";
      };
      "org/gnome/desktop/wm/preferences" = {
        theme = "${config.gtk.theme.name}";
      };
    };
  };

  services.dropbox = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      git_commit = {
        tag_disabled = false;
      };

      time = {
        disabled = false;
      };
    };
  };
}
