{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;

        swtpm.enable = true;
      };
    };
  };
}
