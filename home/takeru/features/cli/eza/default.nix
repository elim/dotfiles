{ pkgs, ... }:

{
  programs.eza = {
    enable = true;
    icons = "always";
    git = true;
    theme = import ./themes/nord.nix;
  };
}
