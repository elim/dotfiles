{
  hardware.uinput.enable = true;

  imports = [
    ./nvidia.nix
    ./power.nix
  ];
}
