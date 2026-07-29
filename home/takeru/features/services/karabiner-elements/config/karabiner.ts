import { ifApp, map, rule, simpleModifications } from "karabiner.ts";
import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const karabinerJsonPath = fileURLToPath(
  new URL("./karabiner.json", import.meta.url),
);

const emacsLikeExcludedApps = ifApp({
  bundle_identifiers: [/^org\.gnu\.Emacs$/, /^com\.github\.wez\.wezterm$/],
}).unless();

const emacsLikeCursorMovement = rule(
  "Emacs-like cursor movement",
  emacsLikeExcludedApps,
).manipulators([
  map("b", "control").to("left_arrow"),
  map("f", "control").to("right_arrow"),
  map("p", "control").to("up_arrow"),
  map("n", "control").to("down_arrow"),
]);

const emacsLikeClipboard = rule(
  "Emacs-like clipboard",
  emacsLikeExcludedApps,
).manipulators([
  map("k", "control")
    .to("right_arrow", ["command", "shift"])
    .to("x", "command"),
  map("y", "control").to("v", "command"),
]);

const emacsLikeBasicInput = rule(
  "Emacs-like basic input",
  emacsLikeExcludedApps,
).manipulators([
  map("i", "control").to("tab"),
  map("m", "control").to("return_or_enter"),
  map("open_bracket", "control").to("escape"),
]);

const config = {
  global: {
    show_in_menu_bar: true,
  },
  profiles: [
    {
      complex_modifications: {
        rules: [
          emacsLikeCursorMovement.build(),
          emacsLikeClipboard.build(),
          emacsLikeBasicInput.build(),
        ],
      },
      name: "Default profile",
      selected: true,
      virtual_hid_keyboard: {
        keyboard_type_v2: "ansi",
      },
      simple_modifications: simpleModifications([
        map("caps_lock").to("left_control"),
      ]),
    },
  ],
};

writeFileSync(karabinerJsonPath, `${JSON.stringify(config, null, 2)}\n`);
