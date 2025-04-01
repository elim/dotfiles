let
  inherit (import ../function.nix) altToMetaRemapper mkKeyMap;
  inherit (import ../keys.nix) numberKeys;

  altToMetaMap = mkKeyMap altToMetaRemapper numberKeys;

  application = {
    only = [
      "org.gnome.Terminal"
    ];
  };

  remap = altToMetaMap;
in
[
  {
    name = "For Gnome Terminal";
    inherit application;
    inherit remap;
  }
]
