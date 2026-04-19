{ pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };

      efi = {
        canTouchEfiVariables = true;
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;

    # Based on https://nixos.wiki/wiki/Yubikey_based_Full_Disk_Encryption_(FDE)_on_NixOS
    initrd = {
      systemd = {
        enable = true;
        fido2.enable = true;
      };

      kernelModules = [
        "dm-snapshot"
        "kvm-intel"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "vfat"
      ];

      luks = {
        devices = {
          "nixos-enc" = {
            device = "/dev/nvme0n1p2";
            preLVM = true;
            crypttabExtraOpts = [ "fido2-device=auto" ];
          };
        };
      };
    };
  };
}
