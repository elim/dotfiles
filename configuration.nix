# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  require = path: pkgs.callPackage (import path);

  unstable = import <nixos-unstable> {
    config.allowUnfree = true;
  };
  my = import ./myself.nix;

  fcitx5-skk = require ./packages/fcitx5-skk.nix { inherit (pkgs.libsForQt5) fcitx5-qt; };
in
{
  imports =
    [
      ./hardware-configuration.nix

      ./fonts.nix
      ./fprint.nix
      ./networking.nix
      ./samba.nix
      ./security.nix
    ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  nixpkgs.overlays = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Based on https://nixos.wiki/wiki/Yubikey_based_Full_Disk_Encryption_(FDE)_on_NixOS
  #
  # Minimal list of modules to use the EFI system partition and the YubiKey
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "kvm-intel"
    "nls_cp437"
    "nls_iso8859-1"
    "usbhid"
    "vfat"
  ];

  # Enable support for the YubiKey PBA
  boot.initrd.luks.yubikeySupport = true;

  # Configuration to use your Luks device
  boot.initrd.luks.devices = {
    "nixos-enc" = {
      device = "/dev/nvme0n1p2";
      preLVM = true; # You may want to set this to false if you need to start a network service first
      yubikey = {
        slot = 2;
        twoFactor = true; # Set to false if you did not set up a user password.
        storage = {
          device = "/dev/nvme0n1p1";
        };
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "latarcyrheb-sun32";
    #   keyMap = "us";
    useXkbConfig = true;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    displayManager.lightdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = true;
        tappingDragLock = false;
      };
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-skk ];
    };
  };

  # Enable CUPS to print documents.
  services = {
    printing = {
      enable = true;
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;


  services.thermald.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${my.username}" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "docker"
      "input"
      "libvirtd"
      "networkmanager"
      "wheel" # Enable ‘sudo’ for the user.
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # develop
    gcc
    git
    gnumake
    vim

    # gnome
    gnome.gnome-terminal

    # gnupg
    gnome.gnome-keyring
    gnupg
    pinentry

    # libvert
    spice-gtk
    virt-manager
  ] ++ (with unstable; [
  ]);

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        # https://www.reddit.com/r/NixOS/comments/ulzr88/comment/i7ypv20/?context=3
        ovmf = {
          enable = true;
          packages = [
            pkgs.OVMFFull.fd
          ];
        };
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  environment = {
    etc = {
      # https://www.reddit.com/r/NixOS/comments/ulzr88/comment/i7ypv20/?context=3
      "ovmf/edk2-x86_64-secure-code.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
      };

      "ovmf/edk2-i386-vars.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
        mode = "0644";
        user = "libvirtd";
      };

      # Based upon #tech-linux channel which in the vim-jp Slack workspace and
      # https://github.com/rvaiya/keyd/issues/66#issuecomment-985980317
      "libinput/local-overrides.quirks" = {
        text = ''
          [Serial Keyboards]
          MatchUdevType=keyboard
          MatchName=py-evdev-uinput
          AttrKeyboardIntegration=internal
        '';
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs = {
    _1password = {
      enable = true;
    };

    _1password-gui = {
      enable = true;

      polkitPolicyOwners = [ "${my.username}" ];
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.seahorse.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;

  # List services that you want to enable:

  services.gnome = {
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.dbus.packages = [
    pkgs.gnome3.gnome-keyring
    pkgs.gcr
  ];

  # For Xremap
  # https://github.com/k0kubun/xremap/tree/v0.2.2#prerequisite
  services.udev = {
    extraRules = ''
      KERNEL=="uinput", GROUP="input"
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
