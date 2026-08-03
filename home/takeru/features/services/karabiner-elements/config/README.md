# Karabiner-Elements config

`karabiner.ts` is the source of truth in this directory.

## Build

```bash
nix develop .#karabiner-ts
bun install
bun run build
```

Commit the generated `karabiner.json` together with source changes.

## Deploy

```bash
home-manager switch --flake .#takeru.naito@emerald
```

Karabiner-Elements reads `~/.config/karabiner/karabiner.json`; `bun run build` only updates the repo-local generated file.

The deployed config directory is managed by Home Manager, so changes made in the Karabiner-Elements UI are not expected to persist. Update `karabiner.ts` instead.

## Emacs-like bindings

The bindings apply to GUI applications except Emacs and WezTerm.

| Input                      | Action                                                      |
| -------------------------- | ----------------------------------------------------------- |
| `C-b`, `C-f`, `C-p`, `C-n` | Move by character or line                                   |
| `C-a`, `C-e`               | Move to the beginning or end of the line                    |
| `M-b`, `M-f`               | Move by word                                                |
| `C-v`, `M-v`               | Move by page                                                |
| `M-<`, `M->`               | Move to the beginning or end of the document                |
| `C-Space`                  | Toggle the mark                                             |
| `C-M-Space`                | Select the next word and enable the mark                    |
| `C-g`                      | Disable the mark, or send Escape when the mark is disabled  |
| `C-w`, `C-k`, `C-u`        | Cut the selection, to line end, or to line beginning        |
| `M-d`, `M-Backspace`       | Kill the next or previous word                              |
| `C-y`                      | Paste from the macOS clipboard                              |
| `C-d`, `C-h`               | Delete forward or backward                                  |
| `C-o`                      | Open a line                                                 |
| `C-i`, `C-m`, `C-[`        | Send Tab, Return, or Escape                                 |
| `C-/`, `C-Shift-\\`        | Undo                                                        |
| `C-s`, `C-r`, `M-%`        | Find, find previous, or open replace if the app supports it |
| `C-x h`                    | Select all and enable the mark                              |
| `C-x C-f`, `C-x C-s`       | Open or save                                                |
| `C-x k`, `C-x C-c`         | Close or quit                                               |
| `C-x u`                    | Undo                                                        |
| `C-q KEY`                  | Quoted insert: send the next key without conversion         |

Movement extends the selection while the mark is enabled. Kill and yank
commands use the standard macOS clipboard.

Karabiner-Elements cannot safely clear a GUI application's visual selection
without sending an application-dependent key. Therefore, `C-g` disables the
mark state but may leave the current selection visible.
