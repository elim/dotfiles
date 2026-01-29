{ pkgs }:

pkgs.mkShell {
  buildInputs = [
    pkgs.slackdump
    pkgs.chromium
  ];

  shellHook = ''
    export ROD_BIN="${pkgs.chromium}/bin/chromium"

    echo "🔐 Slackdump authentication environment loaded."
    echo "Chromium path: $ROD_BIN"
    echo "Run 'slackdump' to start the login wizard."
  '';
}
