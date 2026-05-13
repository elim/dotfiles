{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      nodejs # npm is for "add-node-modules-path" Emacs Lisp Package.
      typescript-language-server
    ];
  };
}
