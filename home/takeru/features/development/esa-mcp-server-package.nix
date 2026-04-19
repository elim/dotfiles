{
  config,
  lib,
  pkgs,
  mcp-servers-nix,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  esa-mcp-server = mcp-servers-nix.packages.${system}.esa-mcp-server;
in
pkgs.writeShellScriptBin "esa-mcp" ''
  export ESA_ACCESS_TOKEN="$(cat ${config.sops.secrets."esa/access_token".path})"
  export LANG="ja"

  exec ${lib.getExe esa-mcp-server} "$@"
''
