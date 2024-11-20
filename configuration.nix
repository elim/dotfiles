# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  ...
}:

let
  require = path: pkgs.callPackage (import path);
in
{
  imports = [ ./modules ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  nixpkgs.overlays = [ ];

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

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
    xkb.options = "ctrl:nocaps,altwin:swap_lalt_lwin";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      tapping = true;
      tappingDragLock = false;
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # ref: https://discourse.nixos.org/t/49266/18
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "555.58.02";
      sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
      sha256_aarch64 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
      openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
      settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
      persistencedSha256 = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
    };

    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-skk
        fcitx5-skk-qt
        libsForQt5.fcitx5-qt
      ];
    };
  };

  # Enable CUPS to print documents.
  services = {
    printing = {
      enable = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };

  # Enable sound.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  services.thermald.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # develop
    gcc
    git
    gnumake
    vim

    # gnome
    gnome-terminal

    # gnupg
    gnome-keyring
    gnupg
    pinentry

    # libvert
    spice-gtk
    virt-manager
  ];

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
          packages = [ pkgs.OVMFFull.fd ];
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

      polkitPolicyOwners = [ config.users.users.default.name ];
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
    pkgs.gnome-keyring
    pkgs.gcr
  ];

  # For Xremap
  # https://github.com/k0kubun/xremap/tree/v0.2.2#prerequisite
  services.udev = {
    extraRules = ''
      KERNEL=="uinput", GROUP="input"
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
