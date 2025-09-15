{ config, ... }:
{
  imports = [
    ./bash
    ./direnv.nix
    ./home-manager.nix
    ./nix-your-shell.nix
    ./readline.nix
    ./starship.nix
    ./zsh
  ];
}
