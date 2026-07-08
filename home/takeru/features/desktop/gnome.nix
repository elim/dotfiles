{ config, pkgs, ... }:
{
  dconf = {
    settings = {
      "org/gnome/desktop/input-sources" = {
        xkb-options = [ ];
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        accel-profile = "adaptive";
        click-method = "fingers";
        disable-while-typing = true;
        edge-scrolling-enabled = false;
        natural-scroll = true;
        speed = 0.15;
        tap-and-drag = false;
        tap-and-drag-lock = false;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
    };
  };

  gtk = {
    enable = true;

    font = {
      name = "HackGen Console NF";
      package = pkgs.hackgen-nf-font;
      size = 14;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      theme = config.gtk.theme;
    };
  };

  home.sessionVariables.GTK_THEME = config.gtk.theme.name;

  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    kimpanel
    xremap
  ];
}
