{ pkgs, ... }:

let
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.toFile "empty.el" "";
    package = pkgs.emacs-unstable-pgtk;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      # Core framework packages
      epkgs.leaf
      epkgs.leaf-keywords
      epkgs.hydra
      epkgs.blackout

      # Completion and navigation framework
      epkgs.vertico
      epkgs.vertico-posframe
      epkgs.consult
      epkgs.embark-consult
      epkgs.marginalia
      epkgs.orderless
      epkgs.affe
      epkgs.company
      epkgs.company-quickhelp

      # UI and appearance
      epkgs.doom-modeline
      epkgs.doom-themes
      epkgs.popwin
      epkgs.rotate
      epkgs.nyan-mode
      epkgs.rainbow-mode

      # Input method
      epkgs.ddskk
      epkgs.ddskk-posframe

      # Programming language major modes
      epkgs.dockerfile-mode
      epkgs.elm-mode
      epkgs.go-mode
      epkgs.js2-mode
      epkgs.json-mode
      epkgs.nix-mode
      epkgs.php-mode
      epkgs.salt-mode
      epkgs.slim-mode
      epkgs.terraform-mode
      epkgs.typescript-mode
      epkgs.web-mode
      epkgs.yaml-mode

      # Markup and documentation modes
      epkgs.markdown-mode
      epkgs.feature-mode
      epkgs.mmm-mode

      # Version control modes
      epkgs.git-modes

      # Code quality and linting
      epkgs.flycheck
      epkgs.flycheck-posframe
      epkgs.editorconfig
      epkgs.eslint-fix
      epkgs.sqlformat

      # Development tools and project management
      epkgs.magit
      epkgs.projectile
      epkgs.browse-at-remote

      # Ruby-specific packages
      epkgs.ruby-end
      epkgs.rubocop
      epkgs.rspec-mode

      # Editor enhancements and utilities
      epkgs.anzu
      epkgs.atomic-chrome
      epkgs.buffer-move
      epkgs.clipmon
      epkgs.elisp-slime-nav
      epkgs.open-junk-file
      epkgs.persistent-scratch
      epkgs.topsy
      epkgs.undo-tree
      epkgs.wgrep
      epkgs.which-key

      # System integration
      epkgs.add-node-modules-path
      epkgs.async

      # Translation
      epkgs.google-translate

      # Tree-sitter grammar support
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
