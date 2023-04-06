{

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.interfaces = [ "wlp0s20f3" ];

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      139
      445
      5357 # wsdd
    ];
    allowedUDPPorts = [
      137
      138
      3702 # wsdd
    ];
  };
}
