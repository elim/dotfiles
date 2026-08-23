{ pkgs }:

# Keep Home Manager and the Nix ERT runner on the same Emacs, package set,
# and Tree-sitter grammars. Both default.nix and flake.nix import this file.
let
  baseEmacs = if pkgs.stdenv.isDarwin then pkgs.emacs31 else pkgs.emacs31-pgtk;
  emacsPackages = pkgs.emacsPackagesFor baseEmacs;
  treeSitterGrammars = emacsPackages.treesit-grammars.with-all-grammars;

  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.toFile "empty.el" "";
    package = baseEmacs;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      # Core framework packages
      epkgs.leaf
      epkgs.leaf-keywords
      epkgs.hydra
      epkgs.blackout

      # Completion and navigation framework
      epkgs.affe
      epkgs.consult
      epkgs.embark-consult
      epkgs.marginalia
      epkgs.orderless
      epkgs.projectile
      epkgs.vertico
      # Code completion and intelligence
      epkgs.company
      epkgs.company-quickhelp
      epkgs.editorconfig
      epkgs.flycheck
      epkgs.flycheck-posframe
      treeSitterGrammars

      # Version control
      epkgs.browse-at-remote
      epkgs.git-modes
      epkgs.magit

      # Programming languages
      epkgs.dockerfile-mode
      epkgs.go-mode
      epkgs.json-mode
      epkgs.nix-mode
      epkgs.slim-mode
      epkgs.terraform-mode
      epkgs.typescript-mode
      epkgs.yaml-mode

      # Ruby support
      epkgs.rspec-mode
      epkgs.rubocop
      epkgs.ruby-end

      # Markup and documentation
      epkgs.feature-mode

      # User interface and themes
      epkgs.doom-modeline
      epkgs.doom-themes
      epkgs.nerd-icons
      epkgs.nyan-mode
      epkgs.popwin
      epkgs.rainbow-delimiters
      epkgs.rotate

      # Input method
      epkgs.ddskk
      epkgs.ddskk-posframe

      # Editor enhancements
      epkgs.anzu
      epkgs.buffer-move
      epkgs.open-junk-file
      epkgs.persistent-scratch
      epkgs.topsy
      epkgs.undo-fu-session
      epkgs.vundo
      epkgs.wgrep
      epkgs.which-key

      # System integration
      epkgs.add-node-modules-path
      epkgs.atomic-chrome
      epkgs.direnv
      epkgs.elisp-slime-nav

      # Translation and utilities
      epkgs.google-translate
    ];
  };
in
{
  inherit emacs treeSitterGrammars;
}
