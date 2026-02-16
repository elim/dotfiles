{ pkgs, ... }:

let
  brave = import ./brave.nix;
  firefox = import ./firefox.nix;
  gnome-terminal = import ./gnome-terminal.nix;
  wezterm = import ./wezterm.nix;

  emacs-like = import ./emacs-like.nix;
  macos-like = import ./macos-like.nix;

  global = import ./global.nix { inherit pkgs; };
in
brave ++ firefox ++ gnome-terminal ++ wezterm ++ macos-like ++ emacs-like ++ global
