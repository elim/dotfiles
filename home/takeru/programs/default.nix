{ config, ... }:
{
  imports = [
    ./bash
    ./bat.nix
    ./direnv.nix
    ./git
    ./home-manager.nix
    ./mpv.nix
    ./nix-your-shell.nix
    ./readline.nix
    ./starship.nix
    ./zsh
  ];
}
