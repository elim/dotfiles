{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # develop
      gcc
      git
      gnumake

      # libvert
      spice-gtk
      virt-manager
    ];
  };
}
