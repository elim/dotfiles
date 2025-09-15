{ pkgs, ... }:

let
  whichpr = pkgs.callPackage ../../../../pkgs/whichpr.nix { inherit pkgs; };
in
{
  home.packages = [ whichpr ];
}
