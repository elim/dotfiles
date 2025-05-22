{
  imports = [
    ./_1password.nix
    ./_1password-gui.nix
    ./dconf.nix
    ./gnupg.nix
    ./nix-ld.nix
    ./seahorse.nix
    ./zsh.nix
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
}
