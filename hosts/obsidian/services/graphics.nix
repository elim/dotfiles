{
  # Note: services.xserver.enable is still required for graphical sessions
  # even when using Wayland. This is a historical naming issue in NixOS
  # that remains for backward compatibility.
  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
