{
  pkgs ? import <nixpkgs> { },
}:

let
  text = builtins.readFile (
    pkgs.replaceVars ./set-docker-detach-keys.sh.in {
      jq = "${pkgs.jq}/bin/jq";
    }
  );
in
pkgs.writeShellApplication {
  name = "set-docker-detach-keys";

  runtimeInputs = with pkgs; [
    coreutils
    jq
  ];

  inherit text;
}
