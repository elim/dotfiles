{ pkgs }:

let
  clip = pkgs.callPackage ../clip { };
  cpath = pkgs.callPackage ../cpath { };
in
pkgs.writeShellApplication {
  name = "slack-context";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.ruby
    pkgs.slackdump
    pkgs.unzip
    clip
    cpath
  ];

  text = ''
    exec ruby ${./slack-context.rb} "$@"
  '';
}
