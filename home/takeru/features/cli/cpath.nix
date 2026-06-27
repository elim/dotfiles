{ pkgs, ... }:

let
  cpath = pkgs.callPackage ../../../../pkgs/cpath { };
in
{
  home.packages = [ cpath ];
}
