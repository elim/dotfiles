let
  inherit (import ../../mark.nix) setMark unsetMark;

  application = {
    not = [
      "/[Ee]macs/"
      "org.gnome.Terminal"
    ];
  };
in
[
  {
    name = "Emacs-like: Mark toglle (on mark unset)";
    inherit application;
    mode = "mark_unset";
    remap = {
      C-space = setMark;
      C-g = "esc";
    };
  }
  {
    name = "Emacs-like: Mark toglle (on mark set)";
    inherit application;
    mode = "mark_set";
    remap = {
      C-space = unsetMark;
      C-g = unsetMark;
    };
  }
  {
    name = "Emacs-like: Hack for Beginning/End of file (on mark unset)";
    inherit application;
    mode = "mark_unset";
    remap = {
      # Beginning/End of file
      M-Shift-comma = {
        with_mark = "C-Home";
      };
      M-Shift-dot = {
        with_mark = "C-End";
      };
    };
  }
  {
    name = "Emacs-like: Hack for eginning/End of file (on mark set)";
    inherit application;
    mode = "mark_set";
    remap = {
      # Beginning/End of file
      M-Shift-comma = {
        with_mark = "C-Shift-Home";
      };
      M-Shift-dot = {
        with_mark = "C-Shift-End";
      };
    };
  }
  {
    # https://github.com/xremap/xremap/blob/v0.16.6/example/emacs.yml
    name = "Emacs-like: basic";
    inherit application;
    remap = {
      # Cursor
      C-b = {
        with_mark = "left";
      };
      C-f = {
        with_mark = "right";
      };
      C-p = {
        with_mark = "up";
      };
      C-n = {
        with_mark = "down";
      };

      # Forward/Backward word
      M-b = {
        with_mark = "C-left";
      };
      M-f = {
        with_mark = "C-right";
      };

      # Beginning/End of line
      C-a = {
        with_mark = "home";
      };
      C-e = {
        with_mark = "end";
      };

      # Page up/down
      M-v = {
        with_mark = "pageup";
      };
      C-v = {
        with_mark = "pagedown";
      };

      # Newline
      C-m = "enter";
      # C-j = "enter";
      C-o = [
        "enter"
        "left"
      ];

      # Copy
      C-w = [
        "C-x"
      ] ++ unsetMark;
      # M-w = [
      #   "C-c"
      # ] ++ unsetMark;
      C-y = [
        "C-v"
      ] ++ unsetMark;

      # Delete
      C-d = [
        "delete"
      ] ++ unsetMark;
      M-d = [
        "C-delete"
      ] ++ unsetMark;

      # Kill line
      C-k = [
        "Shift-end"
        "C-x"
      ] ++ unsetMark;

      # delete backward char
      C-h = [
        "Backspace"
      ] ++ unsetMark;

      # unix-line-discard
      C-u = [
        "Shift-home"
        "C-x"
      ] ++ unsetMark;

      # Kill word backward
      Alt-backspace = [
        "C-backspace"
      ] ++ unsetMark;

      # set mark next word continuously.
      C-M-space = [
        "C-Shift-right"
      ] ++ setMark;

      # Undo
      C-slash = [
        "C-z"
      ] ++ unsetMark;
      C-Shift-ro = "C-z";

      # Search
      C-s = "C-f";

      C-r = "Shift-F3";
      M-Shift-5 = "C-h";

      # C-x YYY
      C-x = {
        remap = {
          # C-x h (select all)
          h = [
            "C-home"
            "C-a"
          ] ++ setMark;
          # C-x C-f (open)
          C-f = "C-o";
          # C-x C-s (save)
          C-s = "C-s";
          # C-x k (kill tab)
          k = "C-f4";
          # C-x C-c (exit)
          C-c = "C-q";
          # C-x u (undo)
          u = [
            "C-z"
          ] ++ unsetMark;
        };
      };
    };
  }
]
