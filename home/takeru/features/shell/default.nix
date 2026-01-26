{ config, ... }:
{
  imports = [
    ./bash
    ./direnv.nix
    ./environment.nix
    ./nix-your-shell.nix
    ./readline.nix
    ./starship.nix
    ./zsh
  ];
}
