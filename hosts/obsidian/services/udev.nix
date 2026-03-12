{
  # For Xremap
  # https://github.com/xremap/xremap/tree/v0.10.8?tab=readme-ov-file#running-xremap-without-sudo
  services.udev = {
    extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"

      # Goodix MOC (27c6:63ac): avoid autosuspend and disable USB persist
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="63ac", TEST=="power/control", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="63ac", TEST=="power/persist", ATTR{power/persist}="0"
    '';
  };
}
