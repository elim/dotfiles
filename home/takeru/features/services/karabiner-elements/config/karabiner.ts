import { ifApp, ifVar, map, rule, simpleModifications } from "karabiner.ts";
import type {
  FromKeyParam,
  FromModifierParam,
  Modifier,
  ToKeyParam,
} from "karabiner.ts";
import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const karabinerJsonPath = fileURLToPath(
  new URL("./karabiner.json", import.meta.url),
);

const emacsLikeMarkVariable = "emacs_like_mark";

const emacsLikeExcludedApps = ifApp({
  bundle_identifiers: [/^org\.gnu\.Emacs$/, /^com\.github\.wez\.wezterm$/],
}).unless();

const mapMarkAware = (
  from: FromKeyParam,
  mandatoryModifiers: FromModifierParam,
  to: ToKeyParam,
  toModifiers: Modifier[] = [],
) => {
  const withoutMark = map(from, mandatoryModifiers).condition(
    ifVar(emacsLikeMarkVariable, true).unless(),
  );

  return [
    map(from, mandatoryModifiers)
      .condition(ifVar(emacsLikeMarkVariable, true))
      .to(to, [...toModifiers, "shift"]),
    toModifiers.length > 0
      ? withoutMark.to(to, toModifiers)
      : withoutMark.to(to),
  ];
};

const emacsLikeMark = rule(
  "Emacs-like mark",
  emacsLikeExcludedApps,
).manipulators([
  map("spacebar", "control")
    .condition(ifVar(emacsLikeMarkVariable, true))
    .toUnsetVar(emacsLikeMarkVariable),
  map("spacebar", "control")
    .condition(ifVar(emacsLikeMarkVariable, true).unless())
    .toVar(emacsLikeMarkVariable, true),
  map("g", "control")
    .condition(ifVar(emacsLikeMarkVariable, true))
    .toUnsetVar(emacsLikeMarkVariable),
  map("g", "control")
    .condition(ifVar(emacsLikeMarkVariable, true).unless())
    .to("escape"),
]);

const emacsLikeCursorMovement = rule(
  "Emacs-like cursor movement",
  emacsLikeExcludedApps,
).manipulators([
  ...mapMarkAware("b", "control", "left_arrow"),
  ...mapMarkAware("f", "control", "right_arrow"),
  ...mapMarkAware("p", "control", "up_arrow"),
  ...mapMarkAware("n", "control", "down_arrow"),
  ...mapMarkAware("a", "control", "left_arrow", ["command"]),
  ...mapMarkAware("e", "control", "right_arrow", ["command"]),
  ...mapMarkAware("b", "option", "left_arrow", ["option"]),
  ...mapMarkAware("f", "option", "right_arrow", ["option"]),
  ...mapMarkAware("v", "control", "page_down"),
  ...mapMarkAware("v", "option", "page_up"),
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

const emacsLikeQuotedInsert = rule(
  "Emacs-like quoted insert",
  emacsLikeExcludedApps,
).manipulators([
  map("q", "control")
    .toVar("emacs_like_quote", true)
    .toDelayedAction(
      [
        {
          set_variable: {
            name: "emacs_like_quote",
            value: false,
          },
        },
      ],
      [],
    ),
  map("i", "control")
    .condition(ifVar("emacs_like_quote", true))
    .to("i", "control")
    .toUnsetVar("emacs_like_quote"),
  map({
    any: "key_code",
    modifiers: {
      optional: ["any"],
    },
  })
    .condition(ifVar("emacs_like_quote", true))
    .toFromEvent()
    .toUnsetVar("emacs_like_quote"),
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
          emacsLikeQuotedInsert.build(),
          emacsLikeMark.build(),
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
