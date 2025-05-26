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
    #
    # Minimal list of modules to use the EFI system partition and the YubiKey
    initrd = {
      kernelModules = [
        "dm-snapshot"
        "kvm-intel"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "vfat"
      ];

      luks = {
        # Enable support for the YubiKey PBA
        yubikeySupport = true;

        # Configuration to use your Luks device
        devices = {
          "nixos-enc" = {
            device = "/dev/nvme0n1p2";
            # You may want to set this to false if you need to start a network service first
            preLVM = true;
            yubikey = {
              slot = 2;
              # Set to false if you did not set up a user password.
              twoFactor = true;
              storage = {
                device = "/dev/nvme0n1p1";
              };
            };
          };
        };
      };
    };
  };
}
