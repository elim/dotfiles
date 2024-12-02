{ config, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;

    open = true;

    # https://github.com/NixOS/nixpkgs/issues/353990#issuecomment-2467063091
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
