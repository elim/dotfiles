{ config, pkgs, ... }:
{
  imports = [
    ./themes.nix
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ ];
    };
  };
}
