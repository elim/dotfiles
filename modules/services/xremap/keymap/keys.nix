{
  alphabetKeys =
    let
      alphabet = "abcdefghijklmnopqrstuvwxyz";
    in
    builtins.genList (i: builtins.substring i 1 alphabet) 26;

  numberKeys = builtins.genList (i: toString i) 10;

  symbolKeys = [
    "Minus"
    "Equal"
    "Comma"
    "Dot"
    "Semicolon"
  ];

}
