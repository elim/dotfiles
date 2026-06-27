{ pkgs }:

let
  clip = pkgs.callPackage ../clip { };
in
pkgs.writeShellApplication {
  name = "cpath";

  runtimeInputs = [
    pkgs.coreutils
    clip
  ];

  text = ''
    if [[ $# -eq 0 ]]; then
      printf 'Usage: cpath PATH...\n' >&2
      exit 2
    fi

    for path in "$@"; do
      realpath -e -- "$path"
    done | clip
  '';
}
