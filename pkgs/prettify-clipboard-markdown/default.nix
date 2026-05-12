{ pkgs }:

let
  clip = pkgs.callPackage ../clip { };
in
pkgs.writeShellApplication {
  name = "prettify-clipboard-markdown";

  runtimeInputs = [
    clip
    pkgs.prettier
    pkgs.bat
  ];

  text = ''
    # Prettify Markdown content in clipboard and update it
    # Also displays the result with bat

    set -euo pipefail

    # Get clipboard content, format it, copy back, and display
    clip \
      | prettier --tab-width 4 --stdin-filepath temp.md \
      | tee >(clip) \
      | bat --language=markdown --style=plain
  '';
}
