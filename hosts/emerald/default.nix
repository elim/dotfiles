{
  imports = [
    ../../modules/common/nix-settings.nix
    ../../modules/common/nix-gc.nix
  ];

  networking.hostName = "emerald";

  system.stateVersion = 6;
}
