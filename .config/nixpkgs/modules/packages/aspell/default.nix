{ pkgs }:
pkgs.aspellWithDicts (
  dicts: with dicts; [
    en
    en-computers
    en-science
  ]
)
