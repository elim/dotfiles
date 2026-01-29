{ config, dotfiles, pkgs, ... }:

{
  # Install sops command for editing encrypted files
  home.packages = [ pkgs.sops ];

  sops = {
    # Default sops file
    defaultSopsFile = "${dotfiles}/secrets/default.yaml";

    # Use GPG for encryption/decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    # Test secret configuration
    secrets.test_key = {
      # Reads test_key from secrets/default.yaml
      # The decrypted file path can be referenced via config.sops.secrets.test_key.path
    };
  };
}
