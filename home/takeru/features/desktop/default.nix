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
    ./todoist-electron.nix
    ./thunderbird.nix
    ./wezterm
    ./zenity.nix
    ./zoom-us.nix
  ];
}
