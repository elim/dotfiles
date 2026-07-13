{ pkgs }:

let
  clip = pkgs.callPackage ../clip { };
  cpath = pkgs.callPackage ../cpath { };
in
pkgs.writeShellApplication {
  name = "slack-context";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.slackdump
    pkgs.unzip
    clip
    cpath
  ];

  text = ''
    usage() {
      cat >&2 <<'USAGE'
    Usage: slack-context [SLACKDUMP_DUMP_ARGS...]

    Dump Slack content with slackdump, extract the archive, and copy the
    extracted JSON path(s) to the clipboard.

    Examples:
      slack-context
      slack-context -time-from 2026-07-03 -time-to 2026-07-04 "$(clip)"
      slack-context -files=false https://example.slack.com/archives/...
    USAGE
    }

    if [[ $# -eq 1 ]]; then
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
      esac
    fi

    if [[ $# -eq 0 ]]; then
      set -- "$(clip)"
    fi

    before=$(mktemp)
    after=$(mktemp)
    cleanup() {
      rm -f "$before" "$after"
    }
    trap cleanup EXIT

    find . -maxdepth 1 -type f -name 'slackdump*.zip' -printf '%P\n' | sort > "$before"

    slackdump dump "$@"

    find . -maxdepth 1 -type f -name 'slackdump*.zip' -printf '%P\n' | sort > "$after"
    zip_file=$(comm -13 "$before" "$after" | tail -n 1)

    if [[ -z "$zip_file" ]]; then
      printf 'slack-context: slackdump did not create a new zip file\n' >&2
      exit 1
    fi

    mapfile -t entries < <(unzip -Z1 -- "$zip_file")
    json_paths=()
    file_paths=()

    for entry in "''${entries[@]}"; do
      if [[ "$entry" == */ ]]; then
        continue
      fi

      file_paths+=("./$entry")

      if [[ "$entry" == *.json ]]; then
        json_paths+=("./$entry")
      fi
    done

    unzip -o -- "$zip_file"

    if [[ ''${#json_paths[@]} -gt 0 ]]; then
      copied_paths=()
      for path in "''${json_paths[@]}"; do
        copied_paths+=("$(realpath -e -- "$path")")
      done
    else
      copied_paths=()
      for path in "''${file_paths[@]}"; do
        copied_paths+=("$(realpath -e -- "$path")")
      done
    fi

    if [[ ''${#copied_paths[@]} -eq 0 ]]; then
      printf 'slack-context: zip file did not contain files\n' >&2
      exit 1
    fi

    cpath "''${copied_paths[@]}"
    rm -f -- "$zip_file"

    printf 'Copied to clipboard:\n' >&2
    printf '%s\n' "''${copied_paths[@]}" >&2
  '';
}
