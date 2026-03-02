{
  lib,
  pkgs,
  options,
  ...
}:
let
  hasInterval = lib.hasAttrByPath [ "nix" "gc" "interval" ] options;
in
{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  }
  // (lib.optionalAttrs pkgs.stdenv.isLinux { dates = "weekly"; })
  // (lib.optionalAttrs (pkgs.stdenv.isDarwin && hasInterval) {
    interval = [
      {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      }
    ];
  });
}
