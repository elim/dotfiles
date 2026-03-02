{ config, pkgs, ... }:

let
  require = path: pkgs.callPackage (import path);
in
{
  imports = [
    ../../modules/common/nix-gc.nix
    ../../modules/common/nix-settings.nix
    ../../modules/nixos/nix-system.nix

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
