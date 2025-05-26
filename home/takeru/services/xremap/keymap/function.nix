rec {
  mkRemapper = preModifier: postModifier: key: {
    "${preModifier}-${key}" = "${postModifier}-${key}";
  };

  altToCtrlRemapper = mkRemapper "Alt" "Ctrl";
  altToMetaRemapper = mkRemapper "Alt" "Win";
  altToAltPreserver = mkRemapper "Alt" "Alt";

  mkKeyMap = remapper: keys: builtins.foldl' (acc: x: acc // x) { } (map remapper keys);

}
