{ config, pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts
    (dicts: with dicts; [ en en-computers en-science ]);
  unstable = import <nixpkgs-unstable> {};
in {
  home.packages = with pkgs; [
    aspell
    emacs
    xkeysnail
    xorg.xhost
  ];
}
