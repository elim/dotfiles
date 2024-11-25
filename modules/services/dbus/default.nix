{ pkgs, ... }:
{
  services.dbus = {
    packages = [
      pkgs.gnome-keyring
      pkgs.gcr
    ];
  };
}
