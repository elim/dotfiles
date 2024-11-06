{ pkgs }:
# https://github.com/NixOS/nixpkgs/blob/6fb9c58356773f245b01beda9e42a994792238c3/pkgs/by-name/al/albert/package.nix#L16-L24
pkgs.albert.overrideAttrs (oldAttrs: rec {
  version = "0.26.6";
  src = pkgs.fetchFromGitHub {
    owner = "albertlauncher";
    repo = "albert";
    rev = "v${version}";
    hash = "sha256-Z4YgqqtJPYMzpnMt74TX2Hi0AEMyhRc2QHSVuwuaxfE=";
    fetchSubmodules = true;
  };
})
