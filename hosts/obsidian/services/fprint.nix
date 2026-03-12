{ pkgs, ... }:

let
  goodixReset = pkgs.callPackage ../../../pkgs/goodix-reset { };
in
{
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  environment.systemPackages = [
    goodixReset
  ];
}
