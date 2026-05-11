{ pkgs, ... }:

let
  macos-trash = pkgs.callPackage ../../../../pkgs/macos-trash { };
in
{
  home.packages = [ macos-trash ];
}
