{ pkgs, ... }:

let
  brave = import ./brave;
  firefox = import ./firefox;
  gnome-terminal = import ./gnome-terminal;

  emacs-like = import ./emacs-like;
  macos-like = import ./macos-like;

  global = import ./global { inherit pkgs; };
in
brave ++ firefox ++ gnome-terminal ++ macos-like ++ emacs-like ++ global
