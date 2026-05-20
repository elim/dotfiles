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
