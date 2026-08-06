{
  pkgs ? import <nixpkgs> { },
}:

let
  mkCommand =
    {
      name,
      view,
    }:
    let
      text = builtins.readFile (
        pkgs.replaceVars ./command.sh.in {
          emacsclient = "${pkgs.emacs}/bin/emacsclient";
          view = if view then "t" else "nil";
        }
      );
    in
    pkgs.writeShellApplication {
      inherit name text;

      runtimeInputs = with pkgs; [
        coreutils
        emacs
      ];
    };
in
pkgs.symlinkJoin {
  name = "emacsclient-commands";
  paths = [
    (mkCommand {
      name = "e";
      view = false;
    })
    (mkCommand {
      name = "v";
      view = true;
    })
  ];
}
