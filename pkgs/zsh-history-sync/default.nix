{ pkgs }:

let
  ruby = if pkgs ? ruby_4_0 then pkgs.ruby_4_0 else pkgs.ruby_3_4;

  zsh-history-utils = pkgs.callPackage ../zsh-history-utils.nix { };

  src = builtins.path {
    path = ./.;
    name = "zsh-history-sync-src";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "zsh-history-sync";
  version = "0-unstable";

  dontUnpack = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D ${src}/bin/zsh-history-sync $out/share/zsh-history-sync/bin/zsh-history-sync
    cp -R ${src}/lib $out/share/zsh-history-sync/lib

    makeWrapper ${ruby}/bin/ruby $out/bin/zsh-history-sync \
      --add-flags "$out/share/zsh-history-sync/bin/zsh-history-sync" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          zsh-history-utils
          pkgs.openssh
          pkgs.coreutils
        ]
      }

    runHook postInstall
  '';
}
