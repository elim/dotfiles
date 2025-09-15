{ pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts (
    dicts: with dicts; [
      en
      en-computers
      en-science
    ]
  );
in
{
  home.packages = [ aspell ];
}
