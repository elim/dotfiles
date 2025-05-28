{
  pkgs ? import <nixpkgs> { },
  emacs,
}:

let
  text = builtins.readFile (
    pkgs.replaceVars ./e.sh.in {
      emacsclient = "${emacs}/bin/emacsclient";
    }
  );
in
pkgs.writeShellApplication {
  name = "e";

  runtimeInputs = with pkgs; [
    coreutils
    emacs
  ];

  inherit text;
}
