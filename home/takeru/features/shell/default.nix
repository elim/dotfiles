{ config, ... }:
{
  imports = [
    ./bash
    ./direnv.nix
    ./nix-your-shell.nix
    ./readline.nix
    ./starship.nix
    ./zsh
  ];
}
