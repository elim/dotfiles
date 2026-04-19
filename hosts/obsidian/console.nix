{ pkgs, ... }:
{
  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # Use a large PSF font by absolute store path so initrd and the main system
    # resolve the same asset on HiDPI consoles.
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    earlySetup = true;
    # keyMap = "us";
    useXkbConfig = true;
  };
}
