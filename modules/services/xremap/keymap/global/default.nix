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
      C-q = {
        escape_next_key = true;
      };
      Win-Space = {
        launch = [
          albert
          "toggle"
        ];
      };
    };
  }
]
