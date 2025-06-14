{ pkgs, ... }:

{
  home = {
    file = {
      ".emacs.d/init.el".source = ./init.el;
      ".emacs.d/early-init.el".source = ./early-init.el;
    };

    packages = [ pkgs.emacs ];
  };
}
