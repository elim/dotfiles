{
  pkgs,
  stdenv,
  lib,
  backend ? null,
}:

# Clipboard utility inspired by zpm-zsh/clipboard
# https://github.com/zpm-zsh/clipboard

let
  # Determine clipboard backend at build time
  selectedBackend =
    if backend != null then
      backend
    else if stdenv.isDarwin then
      "darwin"
    else
      "wayland"; # Default to Wayland on Linux

  # Backend-specific configuration
  backendConfig = {
    darwin = {
      copyCmd = "pbcopy";
      pasteCmd = "pbpaste";
      runtimeInputs = [ ]; # Built-in commands
    };
    wayland = {
      copyCmd = "wl-copy";
      pasteCmd = "wl-paste";
      runtimeInputs = [ pkgs.wl-clipboard ];
    };
  };

  config = backendConfig.${selectedBackend};
in
pkgs.writeShellApplication {
  name = "clip";

  runtimeInputs = config.runtimeInputs;

  text = ''
    # Cross-platform clipboard utility (context-aware)
    # Usage: clip              → paste from clipboard
    #        echo "text" | clip → copy to clipboard
    #        clip "text"       → copy to clipboard
    #        clip < file.txt   → copy to clipboard
    #
    # Backend: ${selectedBackend}

    # Determine action based on context
    if [[ -t 0 ]] && [[ $# -eq 0 ]]; then
      # No stdin, no args → paste
      ${config.pasteCmd}
    elif [[ ! -t 0 ]]; then
      # Has stdin → copy from stdin
      ${config.copyCmd}
    elif [[ $# -gt 0 ]]; then
      # Has args → copy from args
      printf "%s" "$*" | ${config.copyCmd}
    fi
  '';
}
