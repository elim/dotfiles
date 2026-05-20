import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const karabinerJsonPath = fileURLToPath(
  new URL("./karabiner.json", import.meta.url),
);

const config = {
  global: {
    show_in_menu_bar: true,
  },
  profiles: [
    {
      complex_modifications: {
        rules: [],
      },
      name: "Default profile",
      selected: true,
      virtual_hid_keyboard: {
        keyboard_type_v2: "ansi",
      },
      simple_modifications: [],
    },
  ],
};

writeFileSync(karabinerJsonPath, `${JSON.stringify(config, null, 2)}\n`);
