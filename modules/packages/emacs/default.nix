# Based on "Integrating Tree-Sitter with Emacs29 in nix-darwin"
# https://nohzafk.github.io/posts/2023-12-18-nix-emacs-treesit-grammars/
{ pkgs }:
let
  buildEmacs = (pkgs.emacsPackagesFor pkgs.emacs30).emacsWithPackages;
  treesitGrammars = (pkgs.emacsPackagesFor pkgs.emacs30).treesit-grammars.with-all-grammars;
in
buildEmacs (epkgs: with epkgs; [ treesitGrammars ])
