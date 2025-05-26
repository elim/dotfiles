{ config, pkgs, ... }:

let
  require = path: pkgs.callPackage (import path);
in
{
  imports = [
    ./hardware-configuration.nix

    ./boot.nix
    ./console.nix
    ./environment
    ./fonts.nix
    ./hardware
    ./i18n.nix
    ./networking.nix
    ./programs
    ./security.nix
    ./services
    ./system.nix
    ./time.nix
    ./users.nix
    ./virtualisation
  ];
}
