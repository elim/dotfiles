{
  imports = [
    ./docker.nix
    ./libvirtd.nix
  ];

  virtualisation = {
    spiceUSBRedirection = {
      enable = true;
    };
  };
}
