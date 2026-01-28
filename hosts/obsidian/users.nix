{ pkgs, ... }:

{
  users.users.default = {
    name = "takeru";
    description = "Takeru Naito";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.zsh;
    extraGroups = [
      "docker"
      "input"
      "libvirtd"
      "networkmanager"
      "uinput"
      "wheel"
    ];
  };
}
