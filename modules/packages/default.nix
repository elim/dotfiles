{ pkgs, pinned-pkgs, ... }:

let
  albert = import ./albert { inherit pkgs; };
  aspell = import ./aspell { inherit pkgs; };
  azure-cli = pkgs.azure-cli.override { withImmutableConfig = false; };
  e = import ./e { inherit pkgs emacs; };
  emacs = import ./emacs { inherit pkgs; };
  handbrake = pinned-pkgs.ffmpeg.handbrake;
  set-docker-detach-keys = import ./set-docker-detach-keys { inherit pkgs; };
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
      ruby_3_4
      set-docker-detach-keys
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

  home.activation = {
    setDockerDetachKeys = ''
      ${set-docker-detach-keys}/bin/set-docker-detach-keys
    '';
  };

  home.sessionVariables = {
    EDITOR = "${e}/bin/e";
    GIT_EDITOR = "${emacs}/bin/emacsclient";

    KUBECTL_EXTERNAL_DIFF = "${pkgs.delta}/bin/delta";

    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
