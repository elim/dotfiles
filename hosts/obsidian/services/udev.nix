{
  # For Xremap
  # https://github.com/xremap/xremap/tree/v0.10.8?tab=readme-ov-file#running-xremap-without-sudo
  services.udev = {
    extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"
    '';
  };
}
