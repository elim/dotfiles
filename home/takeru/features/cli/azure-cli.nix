{ pkgs, ... }:

let
  extensions = with pkgs.azure-cli.extensions; [ ssh ];
  azure-cli = pkgs.azure-cli.withExtensions extensions;
in
{
  home.packages = [ azure-cli ];
}
