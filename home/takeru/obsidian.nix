{
  config,
  pkgs,
  pinned-pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "25.05";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  imports = [
    ./features/cli
    ./fonts.nix
    ./gnome
    ./legacies
    ./packages.nix
    ./programs
    ./services
  ];
}
