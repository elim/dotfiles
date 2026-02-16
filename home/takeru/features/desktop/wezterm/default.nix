{ ... }:

{
  programs.wezterm.enable = true;

  xdg.configFile."wezterm" = {
    source = ./config;
    recursive = true;
  };
}
