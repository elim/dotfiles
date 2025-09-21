{ config, pkgs, ... }:
let
  user = config.users.users.default;
in
{
  # https://nixos.wiki/wiki/Samba
  services.samba-wsdd = {
    enable = true;
    discovery = true;
  };

  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        security = "user";
        # use sendfile = yes
        # max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        interfaces = "192.168.122.0/24 virbr0 192.168.10.0/24 wlp0s20f3";
        # hosts allow = 192.168.10 192.168.122 127.0.0.1 localhost
        # hosts deny = 0.0.0.0/0
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "vfs objects" = "fruit streams_xattr";

      };
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
        "force user" = user.name;
        "force group" = "users";
      };
      Photos = {
        path = "/srv/Photos/";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = user.name;
        "force group" = "users";
      };
      TimeMachine = {
        path = "/srv/TimeMachine/";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = user.name;
        "force group" = "users";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
}
