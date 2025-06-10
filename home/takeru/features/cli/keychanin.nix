{
  programs = {
    keychain = {
      enable = true;

      keys = [
        "id_ed25519"
        "0A2D3E0E"
      ];
      extraFlags = [
        "--ssh-allow-forwarded"
        "--ssh-spawn-gpg"
      ];
    };
  };
}
