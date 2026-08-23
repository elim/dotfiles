{ pkgs, ... }:

let
  inherit (import ./package.nix { inherit pkgs; }) emacs;

  overlay =
    final: prev:
    prev
    // {
      inherit emacs;
    };

  emacsclientCommands = pkgs.callPackage ../../../../pkgs/emacsclient-commands {
    pkgs = pkgs.extend overlay;
  };
in

{
  home = {
    file = {
      ".emacs.d/config".source = ./config;
      ".emacs.d/init.el".source = ./init.el;
      ".emacs.d/early-init.el".source = ./early-init.el;
      ".emacs.d/lisp".source = ./lisp;
    };

    packages = [
      emacs
      emacsclientCommands
    ];

    sessionVariables = {
      EDITOR = "${emacs}/bin/emacsclient";
      VISUAL = "${emacs}/bin/emacsclient";
    };
  };
}
