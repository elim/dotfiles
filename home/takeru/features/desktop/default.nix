{ pkgs, ... }:

{
  imports = [
    ./albert.nix
    ./avidemux.nix
    ./brave.nix
    ./firefox.nix
    ./gimp.nix
    ./gnome.nix
    ./handbrake.nix
    ./libreoffice.nix
    ./mpv.nix
    ./slack.nix
    ./thunderbird.nix
    ./zenity.nix
    ./zoom-us.nix
  ];
}
