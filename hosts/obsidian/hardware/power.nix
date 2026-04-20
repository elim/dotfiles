{
  config,
  lib,
  ...
}:

let
  resumeDevice =
    if config.swapDevices == [ ] then
      ""
    else
      let
        firstSwap = lib.head config.swapDevices;
      in
      if firstSwap ? device then firstSwap.device else "/dev/disk/by-label/${firstSwap.label}";
in
{
  assertions = [
    {
      assertion = config.swapDevices != [ ];
      message = "obsidian hibernation expects at least one configured swap device.";
    }
  ];

  powerManagement.enable = true;

  # Reuse the swap device declared in hardware-configuration.nix as the resume target.
  boot.resumeDevice = lib.mkDefault resumeDevice;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "yes";
    AllowSuspendThenHibernate = "yes";
    HibernateDelaySec = "45min";
  };

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 15;
    percentageCritical = 10;
    percentageAction = 7;
    criticalPowerAction = "Hibernate";
  };
}
