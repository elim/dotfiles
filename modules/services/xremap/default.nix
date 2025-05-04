{ pkgs, ... }:
let
  modmap = import ./modmap;
  keymap = import ./keymap { inherit pkgs; };

  inherit (import ./mark.nix) default_mode;
in
{
  services.xremap = {
    withGnome = true;

    debug = true;

    config = {
      inherit default_mode;
      inherit modmap;
      inherit keymap;
    };
  };
}
