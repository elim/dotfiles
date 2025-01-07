{
  pkgs ? import <nixpkgs> { },
  emacs,
}:

let
  substitutions = {
    emacsclient = "${emacs}/bin/emacsclient";
  };

  substituteScript = pkgs.substituteAll {
    src = ./e.sh.in;
    inherit (substitutions) emacsclient;
    isExecutable = true;
  };
in
pkgs.writeShellApplication {
  name = "e";

  runtimeInputs = with pkgs; [
    coreutils
    emacs
  ];

  text = builtins.readFile substituteScript;
}
