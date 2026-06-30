{
  config,
  pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "26.05";

    username = "takeru.naito";
    homeDirectory = "/Users/${username}";
  };

  imports = [
    ../common/nix-gc.nix
    ./features/cli
    ./features/cli/darwin.nix
    ./features/development/mcp.nix
    ./features/emacs
    ./features/security/gpg.nix
    ./features/security/sops.nix
    ./features/services
    ./features/shell
    ./features/xdg.nix
    ./features/legacies

    ./features/desktop/mpv.nix
    ./features/desktop/wezterm
    ./features/fonts.nix
    ./features/home-manager.nix
    ./packages.nix
  ];
}
