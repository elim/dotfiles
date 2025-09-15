{ pkgs, ... }:

{
  home.packages = [ pkgs.nodePackages.sql-formatter ];
}
