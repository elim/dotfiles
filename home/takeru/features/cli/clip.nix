{ pkgs, ... }:

let
  clip = pkgs.callPackage ../../../../pkgs/clip { };
  open = pkgs.callPackage ../../../../pkgs/clip/open.nix { };
in
{
  home.packages = [
    clip
    open
  ];
}
