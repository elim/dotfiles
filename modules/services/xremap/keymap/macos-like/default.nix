let
  inherit (import ../../mark.nix) unsetMark;

  inherit (import ../function.nix) altToCtrlRemapper mkKeyMap;
  inherit (import ../keys.nix) alphabetKeys numberKeys symbolKeys;

  altToCtrlMap = mkKeyMap altToCtrlRemapper (alphabetKeys ++ numberKeys ++ symbolKeys);

  application = {
    not = [
      "/[Ee]macs/"
    ];
  };

  remap = altToCtrlMap // {
    # History back
    Alt-LeftBrace = "Alt-Left";
    # History forward
    Alt-RightBrace = "Alt-Right";
    # Jump to the previous open tab
    Alt-Shift-LeftBrace = "Ctrl-PageUp";
    # Jump to the next open tab
    Alt-Shift-RightBrace = "Ctrl-PageDown";
    # Move Tab to the Left/Up
    Alt-Win-Shift-LeftBrace = "Ctrl-Shift-PageUp";
    # Move Tab to the Right/Down
    Alt-Win-Shift-RightBrace = "Ctrl-Shift-PageDown";
    # Copy
    Alt-c = [ "Ctrl-C" ] ++ unsetMark;
    # Cut
    Alt-x = [ "Ctrl-x" ] ++ unsetMark;
  };
in
[
  {
    name = "macOS Like";
    inherit application;
    inherit remap;
  }
]
