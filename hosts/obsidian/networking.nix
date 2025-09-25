{ pkgs, ... }:

{
  networking = {
    # Define your hostname.
    hostName = "obsidian";

    networkmanager = {
      enable = true;
      plugins = [
        pkgs.networkmanager-openvpn
      ];
    };

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        139 # NetBIOS Session Service
        445 # Microsoft-DS SMB file sharing
        5357 # Web Services for Devices
        1080 # May be used temporarily for internal networking
      ];
      allowedUDPPorts = [
        137 # NETBIOS Name Service
        138 # NETBIOS Datagram Service
        3702 # Web Service Discovery
      ];
    };
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
  };
}
