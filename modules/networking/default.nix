{

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [
      139 # NetBIOS Session Service
      445 # Microsoft-DS SMB file sharing
      5357 # Web Services for Devices
    ];
    allowedUDPPorts = [
      137 # NETBIOS Name Service
      138 # NETBIOS Datagram Service
      3702 # Web Service Discovery
    ];
  };
}
