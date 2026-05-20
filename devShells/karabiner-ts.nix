{ pkgs }:

pkgs.mkShell {
  name = "karabiner-ts";

  packages = [
    pkgs.bun
  ];
}
