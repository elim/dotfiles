{
  config,
  pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "25.11";

    username = "takeru.naito";
    homeDirectory = "/Users/${username}";
  };

  imports = [
    ./features/cli
    ./features/development/mcp.nix
    ./features/emacs
    ./features/security/gpg.nix
    ./features/security/sops.nix
    ./features/services
    ./features/shell
    ./features/legacies

    ./features/desktop/mpv.nix
    ./features/desktop/wezterm
    ./features/fonts.nix
    ./features/home-manager.nix
    ./packages.nix
  ];
}
