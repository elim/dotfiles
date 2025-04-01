let
  inherit (import ../function.nix) altToMetaRemapper mkKeyMap;
  inherit (import ../keys.nix) numberKeys;

  altToMetaMap = mkKeyMap altToMetaRemapper numberKeys;

  application = {
    only = [
      "firefox"
    ];
  };

  remap = altToMetaMap;
in
[
  {
    name = "For Firefox";
    inherit application;
    inherit remap;
  }
]
