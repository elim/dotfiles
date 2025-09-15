{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
