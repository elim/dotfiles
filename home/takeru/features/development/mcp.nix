{
  config,
  lib,
  pkgs,
  mcp-servers-nix,
  ...
}:

let
  # Get esa-mcp-server package from mcp-servers-nix
  esa-mcp-server = mcp-servers-nix.packages.${pkgs.system}.esa-mcp-server;

  # Create wrapper script that injects SOPS secrets
  esa-mcp-wrapper = pkgs.writeShellScript "esa-mcp-wrapper" ''
    export ESA_ACCESS_TOKEN="$(cat ${config.sops.secrets."esa/access_token".path})"
    export LANG="ja"
    exec ${lib.getExe esa-mcp-server} "$@"
  '';

  # MCP configuration JSON
  mcpConfig = pkgs.writeText "esa-mcp-config.json" (
    builtins.toJSON {
      mcpServers = {
        esa = {
          command = "${esa-mcp-wrapper}";
          args = [ ];
        };
      };
    }
  );
in
{
  # Place MCP configuration for Claude Code
  home.file.".config/mcp/esa.json".source = mcpConfig;
}
