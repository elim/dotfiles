{ pkgs }:
let
  commitHash = "92ceff55c9ebc5943853b83287f49fd73a909abd";
  url = "https://github.com/NixOS/nixpkgs/archive/${commitHash}.zip";
  pkgs = import (builtins.fetchTarball { url = url; }) { };
  pkgsWithOverLay = import <nixpkgs> {
    overlays = [
      (prev: final: {
        azure-cli = pkgs.azure-cli;
        python3Packages = pkgs.python3Packages;
      })
    ];
  };
in
pkgsWithOverLay.azure-cli
