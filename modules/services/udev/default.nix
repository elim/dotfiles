{
  # For Xremap
  # https://github.com/k0kubun/xremap/tree/v0.2.2#prerequisite
  services.udev = {
    extraRules = ''
      KERNEL=="uinput", GROUP="input"
    '';
  };
}
