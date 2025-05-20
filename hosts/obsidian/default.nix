{ config, pkgs, ... }:

let
  require = path: pkgs.callPackage (import path);
in
{
  imports = [
    ./hardware-configuration.nix

    ./boot
    ./console
    ./environment
    ./fonts
    ./hardware
    ./i18n
    ./networking
    ./programs
    ./security
    ./services
    ./system
    ./time
    ./users
    ./virtualisation
  ];
}
