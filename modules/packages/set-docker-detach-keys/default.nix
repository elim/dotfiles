{
  pkgs ? import <nixpkgs> { },
}:

let
  substitutions = {
    jq = "${pkgs.jq}/bin/jq";
  };

  substituteScript = pkgs.substituteAll {
    src = ./set-docker-detach-keys.sh.in;
    inherit (substitutions) jq;
    isExecutable = true;
  };
in
pkgs.writeShellApplication {
  name = "set-docker-detach-keys";

  runtimeInputs = with pkgs; [
    coreutils
    jq
  ];

  text = builtins.readFile substituteScript;
}
