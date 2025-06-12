{ pkgs, ... }:

let
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.toFile "empty.el" "";
    package = pkgs.emacs-unstable-pgtk;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      epkgs.elisp-slime-nav
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  overlay =
    final: prev:
    prev
    // {
      inherit emacs;
    };

  e = pkgs.callPackage ../../../pkgs/e { pkgs = (pkgs.extend overlay); };
in

{
  home = {
    file = {
      ".emacs.d/init.el".source = ./init.el;
      ".emacs.d/early-init.el".source = ./early-init.el;
    };

    packages = [
      emacs
      e
    ];

    sessionVariables = {
      EDITOR = "${e}/bin/e";
      GIT_EDITOR = "${emacs}/bin/emacsclient";
    };
  };
}
