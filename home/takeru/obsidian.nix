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
    ./features/desktop
    ./fonts.nix
    ./emacs
    ./legacies
    ./packages.nix
    ./programs
    ./services
  ];
}
