final: prev:
prev
// {
  emacs =
    let
      emacsPackageSet = prev.emacsPackagesFor prev.emacs30-pgtk;
      buildEmacs = emacsPackageSet.emacsWithPackages;
      treesitGrammars = emacsPackageSet.treesit-grammars.with-all-grammars;
    in
    buildEmacs (_: [ treesitGrammars ]);
}
