{ pkgs }:
pkgs.ruby_3_3.overrideAttrs (oldAttrs: rec {
  version = "3.3.4";
  src = pkgs.fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${version}.tar.gz";
    hash = "sha256-/mow+X1U4Cl2jy3fSSNpnEFs28Om6W2z4tVxbH25ajQ=";
  };
})
