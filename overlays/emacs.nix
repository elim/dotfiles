{ self }:

final: prev:
prev
// {
  emacs = prev.emacsWithPackagesFromUsePackage {
    config = builtins.toFile "empty.el" "";
    package = prev.emacs-unstable-pgtk;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
    ];
  };
}
