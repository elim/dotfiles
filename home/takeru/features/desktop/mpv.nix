{ pkgs-stable, ... }:

{
  programs.mpv = {
    enable = true;
    package = pkgs-stable.mpv;
    config = {
      save-position-on-quit = true;
    };
  };
}
