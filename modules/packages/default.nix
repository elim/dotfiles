{ pkgs, pinned-pkgs, ... }:

let
  albert = import ./albert { inherit pkgs; };
  aspell = import ./aspell { inherit pkgs; };
  azure-cli = pinned-pkgs.azure-cli.azure-cli;
  emacs = import ./emacs { inherit pkgs; };
  e = import ./e { inherit pkgs emacs; };
  handbrake = pinned-pkgs.ffmpeg.handbrake;
  ruby = import ./ruby { inherit pkgs; };
  whichpr = import ./whichpr { inherit pkgs; };
in
{
  home.packages =
    with pkgs;
    [
      file
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
      e
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

  home.sessionVariables = {
    EDITOR = "${e}/bin/e";
    GIT_EDITOR = "${emacs}/bin/emacsclient";

    KUBECTL_EXTERNAL_DIFF = "${pkgs.delta}/bin/delta";

    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
