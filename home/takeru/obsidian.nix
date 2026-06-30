{
  config,
  pkgs,
  pinned-pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "26.05";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  imports = [
    ../common/nix-gc.nix
    ./features/cli
    ./features/cli/linux.nix
    ./features/desktop
    ./features/development/mcp.nix
    ./features/development/typescript.nix
    ./features/shell
    ./features/xdg.nix
    ./features/home-manager.nix
    ./features/security/keybase.nix
    ./features/security/sops.nix
    ./features/fonts.nix
    ./features/emacs
    ./features/legacies
    ./packages.nix
    ./features/services
    ./features/services/linux.nix
  ];
}
