{
  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];

    displayManager.lightdm = {
      enable = true;
    };
    desktopManager.gnome = {
      enable = true;
    };

    # Configure keymap in X11
    xkb.options = "ctrl:nocaps,altwin:swap_lalt_lwin";
  };
}
