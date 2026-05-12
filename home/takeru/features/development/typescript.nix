{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      npm # is for "add-node-modules-path" Emacs Lisp Package.
      typescript-language-server
    ];
  };
}
