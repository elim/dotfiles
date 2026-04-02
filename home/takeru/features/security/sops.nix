{
  config,
  dotfiles,
  pkgs,
  ...
}:

let
  claude = import ./claude.nix { inherit dotfiles; };
  esa = import ./esa.nix { inherit dotfiles; };
  jobcan = import ./jobcan.nix { inherit dotfiles; };
  openai = import ./openai.nix { inherit dotfiles; };
in
{
  # Install sops command for editing encrypted files
  home.packages = [ pkgs.sops ];

  sops = {
    # Default sops file
    defaultSopsFile = "${dotfiles}/secrets/default.yaml";

    # Use age for decryption so secrets are available without GPG/pinentry timing.
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Secret configuration
    secrets = claude // esa // jobcan // openai;
  };
}
