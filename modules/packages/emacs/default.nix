# Based on "Integrating Tree-Sitter with Emacs29 in nix-darwin"
# https://nohzafk.github.io/posts/2023-12-18-nix-emacs-treesit-grammars/
{ pkgs }:
let
  emacsPackageSet = pkgs.emacsPackagesFor pkgs.emacs30-pgtk;
  buildEmacs = emacsPackageSet.emacsWithPackages;
  treesitGrammars = emacsPackageSet.treesit-grammars.with-all-grammars;
in
buildEmacs (_: [ treesitGrammars ])
