{ config, ... }:
{
  hardware.nvidia = {
    modesetting.enable = true;

    open = true;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
