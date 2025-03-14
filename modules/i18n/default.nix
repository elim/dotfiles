{ pkgs, ... }:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-skk
          fcitx5-skk-qt
          libsForQt5.fcitx5-qt
        ];
        waylandFrontend =true;
      };
    };
  };
}
