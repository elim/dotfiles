{
  imports = [
    ./_1password
    ./_1password-gui
    ./dconf
    ./gnupg
    ./nix-ld
    ./seahorse
    ./zsh
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
}
