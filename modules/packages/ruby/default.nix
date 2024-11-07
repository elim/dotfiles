{ pkgs }:
pkgs.ruby_3_3.overrideAttrs (oldAttrs: rec {
  version = "3.3.6";
  src = pkgs.fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${version}.tar.gz";
    hash = "sha256-jcSP/68nD4bxAZBT8o5R5NpMzjKjZ2CgYDqa7mfX/Y0=";
  };
})
