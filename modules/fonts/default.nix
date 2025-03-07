{ config, pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
  };

  home.packages = with pkgs; [
    hackgen-font
    hackgen-nf-font
  ];
}
