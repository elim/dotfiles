{ config, pkgs, ... }:
{
  imports = [
    ./themes
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ ];
    };
  };
}
