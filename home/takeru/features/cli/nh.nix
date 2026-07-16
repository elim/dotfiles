{ config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/src/github.com/elim/dotfiles";
in
{
  programs.nh = {
    enable = true;
    flake = dotfilesPath;
  };
}
