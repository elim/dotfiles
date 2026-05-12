# zsh-history-sync

## Purpose

`zsh-history-sync` merges one or more zsh history files into a new history file.

It accepts both local file paths and SSH-style sources, removes exact duplicate
entries automatically, and can clean entries whose commands match user-provided
string or regular expression patterns.

The original history files are not overwritten. By default, the merged result is
written to `./merged-zsh_history`.

Duplicate detection uses the decoded zsh history fields `start_time`,
`finish_time`, and `command`. The first matching entry is kept, and later matches
are removed.

## Usage

```sh
zsh-history-sync [options] SOURCE [SOURCE ...]
```

`SOURCE` can be a local path:

```sh
zsh-history-sync ~/.zsh_history
```

or an SSH-style path:

```sh
zsh-history-sync workstation:~/.zsh_history
zsh-history-sync user@example.com:~/.zsh_history
```

Options:

- `-o`, `--output PATH`: write the merged history to `PATH`.
- `--dry-run`: print entries that would be removed by cleanup or dedupe and exit.
- `--remove-string STRING`: remove entries whose command includes `STRING`.
- `--remove-regexp REGEXP`: remove entries whose command matches `REGEXP`.
- `--verbose`: print progress to stderr.
- `-h`, `--help`: print command help.

## Examples

Merge the local history with two remote histories:

```sh
zsh-history-sync \
  ~/.zsh_history \
  workstation:~/.zsh_history \
  user@example.com:~/.zsh_history
```

Write the result to an explicit output path:

```sh
zsh-history-sync \
  ~/.zsh_history \
  workstation:~/.zsh_history \
  --output ./synced-zsh_history
```

Use it as a cleaner for a single history file:

```sh
zsh-history-sync \
  ~/.zsh_history \
  --remove-string "accidentally pasted text" \
  --output ./cleaned-zsh_history
```

Preview cleanup and dedupe candidates without writing an output file:

```sh
zsh-history-sync \
  ~/.zsh_history \
  workstation:~/.zsh_history \
  --remove-regexp "TOKEN|PASSWORD|SECRET" \
  --dry-run
```
