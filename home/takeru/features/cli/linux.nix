{ pkgs, ... }:

{
  imports = [
    ./docker-client.nix
    ./wl-clipboard.nix
    ./xorg.xhost.nix
  ];
}
