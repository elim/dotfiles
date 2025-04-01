let
  application = {
    only = [
      "Brave-browser"
    ];
  };

  remap = {
    Ctrl-Shift-H = "Ctrl-Shift-H";
  };
in
[
  {
    name = "For Brave";
    inherit application;
    inherit remap;
  }
]
