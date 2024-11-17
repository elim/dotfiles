{
  config,
  pkgs,
  pinned-pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "24.11";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  imports = [
    ./modules
  ];
}
