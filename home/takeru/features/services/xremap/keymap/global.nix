{ pkgs }:
let
  albert = "${pkgs.albert.outPath}/bin/albert";
in
[
  {
    name = "Global";
    remap = {
      C-h = "Backspace";
      C-i = "Tab";
      C-LeftBrace = "ESC";
      C-q = {
        escape_next_key = true;
      };
      Alt-Space = {
        launch = [
          albert
          "toggle"
        ];
      };
    };
  }
]
