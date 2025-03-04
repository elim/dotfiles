{ config, ... }:
{
  imports = [
    ./bash
    ./bat
    ./direnv
    ./git
    ./home-manager
    ./mpv
    ./nix-your-shell
    ./readline
    ./starship
    ./zsh
  ];
}
