{
  config,
  pkgs,
  pinned-pkgs,
  ...
}:

let
  albert = import ./modules/packages/albert { inherit pkgs; };
  aspell = import ./modules/packages/aspell { inherit pkgs; };
  azure-cli = pinned-pkgs.azure-cli.azure-cli;
  emacs = import ./modules/packages/emacs { inherit pkgs; };
  handbrake = pinned-pkgs.ffmpeg.handbrake;
  ruby = import ./modules/packages/ruby { inherit pkgs; };
  whichpr = import ./modules/packages/whichpr { inherit pkgs; };
in
{
  home = rec {
    stateVersion = "24.11";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  imports = [
    ./modules
  ];

  home.packages =
    with pkgs;
    [
      albert
      aspell
      atomicparsley
      avidemux
      azure-cli
      brave
      colordiff
      dash
      delta
      docker-compose
      emacs
      exiftool
      fd
      fdupes
      ffmpeg
      firefox
      ghq
      gimp
      github-cli
      gnomeExtensions.appindicator
      handbrake
      htop
      imagemagick
      k9s
      keychain
      kubectl
      kubelogin
      libreoffice
      nkf
      nodePackages.sql-formatter
      peco
      pgformatter
      ripgrep
      ruby
      shellcheck
      skktools
      slack
      stern
      thunderbird
      tmux
      trurl
      unar
      unzip
      whichpr
      xkeysnail
      xorg.xhost
      xsel
      yq
      zenity
      zoom-us
    ]
    ++ [ pkgs.file ]
    ++ (
      with skkDictionaries;
      map (pkg: pkg.override { useUtf8 = true; }) [
        l
        jinmei
        fullname
        geo
        okinawa
        china_taiwan
        station
        propernoun
        itaiji
        zipcode
      ]
    );

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
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
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

  programs.home-manager.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = true;
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
