let
  inherit (import ./function.nix) altToAltPreserver altToCtrlRemapper mkKeyMap;
  inherit (import ./keys.nix) numberKeys;

  tabSelectMap = mkKeyMap altToAltPreserver numberKeys;
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
      "org.gnome.Terminal"
    ];
  };

  remap = tabSelectMap // viewMap // readlineMap;
in
[
  {
    name = "For Gnome Terminal";
    inherit application;
    inherit remap;
  }
]
