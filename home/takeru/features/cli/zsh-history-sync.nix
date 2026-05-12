{ pkgs, ... }:

let
  zsh-history-sync = pkgs.callPackage ../../../../pkgs/zsh-history-sync { };
in
{
  home.packages = [ zsh-history-sync ];
}
