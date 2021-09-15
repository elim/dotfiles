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
