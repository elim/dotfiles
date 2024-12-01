{
  pkgs ? import <nixpkgs> { },
  emacs,
}:

let
  substitutions = {
    bash = pkgs.bash;
    emacsclient = "${emacs}/bin/emacsclient";
  };

  substituteScript = pkgs.substituteAll {
    src = ./e.sh.in;
    inherit (substitutions) bash emacsclient;
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
