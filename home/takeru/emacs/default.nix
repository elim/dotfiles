{ pkgs, ... }:

let
  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = builtins.toFile "empty.el" "";
    package = pkgs.emacs-unstable-pgtk;
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      # leaf
      epkgs.leaf
      epkgs.leaf-keywords
      epkgs.hydra
      epkgs.blackout

      # environment
      epkgs.add-node-modules-path
      epkgs.affe
      epkgs.async
      epkgs.consult
      epkgs.embark-consult
      epkgs.marginalia
      epkgs.orderless
      epkgs.vertico
      epkgs.vertico-posframe

      epkgs.doom-modeline
      epkgs.doom-themes
      epkgs.popwin
      epkgs.rotate

      # input method
      epkgs.ddskk
      epkgs.ddskk-posframe

      # major modes
      epkgs.dockerfile-mode
      epkgs.elm-mode
      epkgs.feature-mode
      epkgs.git-modes
      epkgs.go-mode
      epkgs.js2-mode
      epkgs.json-mode
      epkgs.markdown-mode
      epkgs.mmm-mode
      epkgs.php-mode
      epkgs.nix-mode
      epkgs.salt-mode
      epkgs.slim-mode
      epkgs.terraform-mode
      epkgs.typescript-mode
      epkgs.web-mode
      epkgs.yaml-mode

      # minor modes
      epkgs.anzu
      epkgs.atomic-chrome
      epkgs.editorconfig
      epkgs.topsy
      epkgs.flycheck
      epkgs.flycheck-posframe
      epkgs.google-translate
      epkgs.nyan-mode

      # development
      epkgs.magit
      epkgs.projectile

      # ruby
      epkgs.ruby-end
      epkgs.rubocop
      epkgs.rspec-mode

      # utils
      epkgs.buffer-move
      epkgs.company
      epkgs.company-quickhelp
      epkgs.browse-at-remote
      epkgs.clipmon
      epkgs.elisp-slime-nav
      epkgs.eslint-fix
      epkgs.open-junk-file
      epkgs.sqlformat
      epkgs.wgrep
      epkgs.which-key
      epkgs.persistent-scratch
      epkgs.undo-tree
      epkgs.rainbow-mode

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
