{ pkgs, ... }:
{
  services.gnome = {
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # gnome
    gnome-terminal

    # gnupg
    gnome-keyring
    gnupg
    pinentry
  ];
}
