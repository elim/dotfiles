{
  config,
  dotfiles,
  pkgs,
  ...
}:

let
  claude = import ./claude.nix { inherit dotfiles; };
  jobcan = import ./jobcan.nix { inherit dotfiles; };
in
{
  # Install sops command for editing encrypted files
  home.packages = [ pkgs.sops ];

  sops = {
    # Default sops file
    defaultSopsFile = "${dotfiles}/secrets/default.yaml";

    # Use GPG for encryption/decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    # Secret configuration
    secrets = claude // jobcan;
  };
}
