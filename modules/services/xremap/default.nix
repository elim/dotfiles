{ pkgs, ... }:
let
  modmap = import ./modmap;
  keymap = import ./keymap { inherit pkgs; };
in
{
  services.xremap = {
    withGnome = true;

    debug = true;

    config = {
      default_mode = "mark_unset";
      inherit modmap;
      inherit keymap;
    };
  };
}
