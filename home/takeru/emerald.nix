{
  config,
  pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "25.05";

    username = "takeru.naito";
    homeDirectory = "/Users/${username}";
  };

  imports = [
    ./features/cli
    ./features/emacs
    ./features/security/gpg.nix
    ./features/services
    ./features/shell
    ./features/legacies

    ./features/desktop/mpv.nix
    ./features/fonts.nix
    ./features/home-manager.nix
    ./packages.nix
  ];
}
