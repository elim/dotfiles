{
  imports = [
    ./docker
    ./libvirtd
  ];

  virtualisation = {
    spiceUSBRedirection = {
      enable = true;
    };
  };
}
