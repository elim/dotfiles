{ pkgs, ... }:
{
  virtualisation = {
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
  };
}
