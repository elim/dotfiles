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
    ./features/development/typescript.nix
    ./features/shell
    ./security/keybase.nix
    ./features/fonts.nix
    ./emacs
    ./features/legacies
    ./packages.nix
    ./features/services
  ];
}
