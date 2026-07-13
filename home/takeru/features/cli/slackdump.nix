{ pkgs, ... }:

let
  slack-context = pkgs.callPackage ../../../../pkgs/slack-context { };
in
{
  home.packages = [
    pkgs.slackdump
    slack-context
  ];
}
