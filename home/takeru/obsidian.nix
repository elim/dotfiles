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
    ./fonts.nix
    ./emacs
    ./legacies
    ./packages.nix
    ./features/services
  ];
}
