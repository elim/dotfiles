{
  config,
  lib,
  pkgs,
  mcp-servers-nix,
  ...
}:

let
  esa-mcp = import ./esa-mcp-server-package.nix {
    inherit
      config
      lib
      pkgs
      mcp-servers-nix
      ;
  };

  claudeProjectMcpConfig = pkgs.writeText "claude-project-mcp.json" (
    builtins.toJSON {
      mcpServers = {
        esa = {
          command = "${lib.getExe esa-mcp}";
          args = [ ];
        };
      };
    }
  );
in
{
  home.packages = [ esa-mcp ];

  # Claude Code reads this via the repo's `.mcp.json` symlink.
  home.file.".config/mcp/esa.json".source = claudeProjectMcpConfig;
}
