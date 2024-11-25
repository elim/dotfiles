{ config, pkgs, ... }:

let
  require = path: pkgs.callPackage (import path);
in
{
  imports = [ ./modules ];
}
