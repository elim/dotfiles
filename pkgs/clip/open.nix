{
  pkgs,
  stdenv,
  lib,
}:

# Open command inspired by zpm-zsh/clipboard
# https://github.com/zpm-zsh/clipboard

let
  # Determine platform at build time
  selectedPlatform = if stdenv.isDarwin then "darwin" else "linux";

  # Platform-specific configuration
  platformConfig = {
    darwin = {
      openCmd = "/usr/bin/open";
      runtimeInputs = [ ]; # Built-in command
    };
    linux = {
      openCmd = "xdg-open";
      runtimeInputs = [ pkgs.xdg-utils ];
    };
  };

  config = platformConfig.${selectedPlatform};
in
pkgs.writeShellApplication {
  name = "open";

  runtimeInputs = config.runtimeInputs;

  text = ''
    # Cross-platform open command
    # Usage: open https://example.com
    #        open file.pdf
    #
    # Platform: ${selectedPlatform}

    if [[ $# -eq 0 ]]; then
      echo "Usage: open <url|file>" >&2
      exit 1
    fi

    ${config.openCmd} "$@"
  '';
}
