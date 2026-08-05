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
const emacsLikePrefixVariable = "emacs_like_c_x";
const emacsLikeQuoteVariable = "emacs_like_quote";

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

const mapRepeatAndUnsetMark = (
  from: FromKeyParam,
  mandatoryModifiers: FromModifierParam,
  to: ToKeyParam,
) =>
  map(from, mandatoryModifiers)
    .to(to, [], { repeat: true })
    .toAfterKeyUp({
      set_variable: {
        name: emacsLikeMarkVariable,
        type: "unset",
      },
    });

const emacsLikeMark = rule(
  "Emacs-like mark",
  emacsLikeExcludedApps,
).manipulators([
  map("spacebar", ["control", "option"])
    .to("right_arrow", ["option", "shift"])
    .toVar(emacsLikeMarkVariable, true),
  map("spacebar", "control")
    .condition(ifVar(emacsLikeMarkVariable, true))
    .toUnsetVar(emacsLikeMarkVariable),
  map("spacebar", "control")
    .condition(ifVar(emacsLikeMarkVariable, true).unless())
    .toVar(emacsLikeMarkVariable, true),
  // Intercept C-g only for mark; otherwise macSKK and the app handle it.
  map("g", "control")
    .condition(ifVar(emacsLikeMarkVariable, true))
    .toUnsetVar(emacsLikeMarkVariable),
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
  ...mapMarkAware("comma", ["option", "shift"], "up_arrow", ["command"]),
  ...mapMarkAware("period", ["option", "shift"], "down_arrow", ["command"]),
]);

const emacsLikeClipboard = rule(
  "Emacs-like clipboard",
  emacsLikeExcludedApps,
).manipulators([
  map("k", "control")
    .to("right_arrow", ["command", "shift"])
    .to("x", "command")
    .toUnsetVar(emacsLikeMarkVariable),
  map("w", "control").to("x", "command").toUnsetVar(emacsLikeMarkVariable),
  map("y", "control").to("v", "command").toUnsetVar(emacsLikeMarkVariable),
]);

const emacsLikeBasicEditing = rule(
  "Emacs-like basic editing",
  emacsLikeExcludedApps,
).manipulators([
  map("o", "control").to("return_or_enter").to("left_arrow"),
  mapRepeatAndUnsetMark("d", "control", "delete_forward"),
  map("d", "option")
    .to("right_arrow", ["option", "shift"])
    .to("x", "command")
    .toUnsetVar(emacsLikeMarkVariable),
  mapRepeatAndUnsetMark("h", "control", "delete_or_backspace"),
  map("u", "control")
    .to("left_arrow", ["command", "shift"])
    .to("x", "command")
    .toUnsetVar(emacsLikeMarkVariable),
  map("delete_or_backspace", "option")
    .to("left_arrow", ["option", "shift"])
    .to("x", "command")
    .toUnsetVar(emacsLikeMarkVariable),
]);

const emacsLikeUndo = rule(
  "Emacs-like undo",
  emacsLikeExcludedApps,
).manipulators([
  map("slash", "control").to("z", "command").toUnsetVar(emacsLikeMarkVariable),
  map("backslash", ["control", "shift"])
    .to("z", "command")
    .toUnsetVar(emacsLikeMarkVariable),
]);

const emacsLikeSearch = rule(
  "Emacs-like search",
  emacsLikeExcludedApps,
).manipulators([
  map("s", "control").to("f", "command"),
  map("r", "control").to("g", ["command", "shift"]),
  map("5", ["option", "shift"]).to("f", ["command", "option"]),
]);

const emacsLikePrefix = rule(
  "Emacs-like C-x prefix",
  emacsLikeExcludedApps,
).manipulators([
  map("x", "control")
    .toVar(emacsLikePrefixVariable, true)
    .toDelayedAction(
      [
        {
          set_variable: {
            name: emacsLikePrefixVariable,
            value: false,
          },
        },
      ],
      [],
    ),
  map("h")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("a", "command")
    .toVar(emacsLikeMarkVariable, true)
    .toUnsetVar(emacsLikePrefixVariable),
  map("f", "control")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("o", "command")
    .toUnsetVar(emacsLikePrefixVariable),
  map("s", "control")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("s", "command")
    .toUnsetVar(emacsLikePrefixVariable),
  map("k")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("w", "command")
    .toUnsetVar(emacsLikePrefixVariable),
  map("c", "control")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("q", "command")
    .toUnsetVar(emacsLikePrefixVariable),
  map("u")
    .condition(ifVar(emacsLikePrefixVariable, true))
    .to("z", "command")
    .toUnsetVar(emacsLikeMarkVariable)
    .toUnsetVar(emacsLikePrefixVariable),
  map({
    any: "key_code",
    modifiers: {
      optional: ["any"],
    },
  })
    .condition(ifVar(emacsLikePrefixVariable, true))
    .toFromEvent()
    .toUnsetVar(emacsLikePrefixVariable),
]);

const emacsLikeQuotedInsert = rule(
  "Emacs-like quoted insert",
  emacsLikeExcludedApps,
).manipulators([
  map("q", "control")
    .toVar(emacsLikeQuoteVariable, true)
    .toDelayedAction(
      [
        {
          set_variable: {
            name: emacsLikeQuoteVariable,
            value: false,
          },
        },
      ],
      [],
    ),
  map({
    any: "key_code",
    modifiers: {
      optional: ["any"],
    },
  })
    .condition(ifVar(emacsLikeQuoteVariable, true))
    .toFromEvent()
    .toUnsetVar(emacsLikeQuoteVariable),
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
          emacsLikePrefix.build(),
          emacsLikeMark.build(),
          emacsLikeCursorMovement.build(),
          emacsLikeClipboard.build(),
          emacsLikeBasicEditing.build(),
          emacsLikeUndo.build(),
          emacsLikeSearch.build(),
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
