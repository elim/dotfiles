{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # develop
      gcc
      git
      gnumake
      vim

      # libvert
      spice-gtk
      virt-manager
    ];
  };
}
