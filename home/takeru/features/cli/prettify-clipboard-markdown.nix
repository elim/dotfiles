{ pkgs, ... }:

let
  prettify-clipboard-markdown = pkgs.callPackage ../../../../pkgs/prettify-clipboard-markdown { };
in
{
  home.packages = [ prettify-clipboard-markdown ];
}
