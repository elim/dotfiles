{ pkgs, ... }:
{
  services = {
    keybase.enable = true;
    kbfs.enable = true;
  };

  home.packages = [ pkgs.keybase-gui ];
}
