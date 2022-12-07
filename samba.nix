{ pkgs, ... }:

# https://nixos.wiki/wiki/Samba
{

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    139
    445
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      # use sendfile = yes
      # max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      interfaces = 192.168.122.0/24 virbr0 192.168.10.0/24 wlp0s20f3
      # hosts allow = 192.168.10 192.168.122 127.0.0.1 localhost
      # hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      homes = {
        browseable = "no";
        "read only" = "yes";
        "guest ok" = "no";
      };
      Music = {
        path = "/srv/Music/";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "takeru";
        "force group" = "users";
      };
      Photos = {
        path = "/srv/Photos/";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "takeru";
        "force group" = "users";
      };
    };
  };
}
