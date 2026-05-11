{ pkgs, ... }:

{
  imports = [
    ./docker-client.nix
    ./gomi.nix
    ./wl-clipboard.nix
    ./xorg.xhost.nix
  ];
}
