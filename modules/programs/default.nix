{ config, ... }:
{
  imports = [
    ./bash
    ./bat
    ./direnv
    ./home-manager
    ./mpv
    ./nix-your-shell
    ./readline
    ./starship
    ./zsh
  ];
}
