{ config, ... }:
{
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
}
