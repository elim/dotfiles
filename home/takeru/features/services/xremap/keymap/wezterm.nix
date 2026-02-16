let
  inherit (import ./function.nix) altToAltPreserver altToMetaRemapper mkKeyMap;
  inherit (import ./keys.nix) numberKeys;

  tabSelectMap = mkKeyMap altToMetaRemapper numberKeys;
  readlineMap = mkKeyMap altToAltPreserver [
    "c"
    "d"
    "l"
    "u"
  ];

  viewMap = {
    # Zoom In
    Alt-Equal = "Ctrl-Shift-Equal";
    # Zoom Out
    Alt-Minus = "Ctrl-Minus";
    # Normal Size
    Alt-0 = "Ctrl-0";
  };

  application = {
    only = [
      "org.wezfurlong.wezterm"
    ];
  };

  remap = tabSelectMap // viewMap // readlineMap;
in
[
  {
    name = "For Wezterm";
    inherit application;
    inherit remap;
  }
]
