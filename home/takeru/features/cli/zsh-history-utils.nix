{ pkgs, ... }:

let
  zsh-history-utils = pkgs.callPackage ../../../../pkgs/zsh-history-utils.nix { };
in
{
  home.packages = [ zsh-history-utils ];
}
