{ pkgs, pkgs-stable, ... }:

let
  aspell = import ./aspell { inherit pkgs; };
  azure-cli = pkgs.azure-cli.withExtensions [ azure-cli.extensions.ssh ];
  e = import ./e { inherit pkgs emacs; };
  emacs = import ./emacs { inherit pkgs; };
  set-docker-detach-keys = import ./set-docker-detach-keys { inherit pkgs; };
  whichpr = import ./whichpr { inherit pkgs; };
  zsh-history-utils = pkgs.callPackage ./zsh-history-utils { };
in
{
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
      docker-client
      e
      emacs
      exiftool
      fd
      fdupes
      ffmpeg
      file
      firefox
      ghq
      gimp
      github-cli
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
      xorg.xhost
      xsel
      yq
      zenity
      zoom-us
      zsh-history-utils
    ]
    ++ (with gnomeExtensions; [
      appindicator
      kimpanel
      xremap
    ])
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
    )
    ++ (with pkgs-stable; [ ]);

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
