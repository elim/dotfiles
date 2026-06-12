{
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  darwinRuntimeDirFallback = "\${XDG_RUNTIME_DIR:-/tmp/xdg-runtime-$(id -u)}";
in
{
  xdg.enable = lib.mkIf isDarwin true;

  home.sessionVariables = lib.mkIf isDarwin {
    # Emacs server uses $XDG_RUNTIME_DIR/emacs before falling back to
    # $TMPDIR/emacs$UID. nix develop rewrites TMPDIR, so keep the socket
    # directory stable for emacsclient launched from development shells.
    XDG_RUNTIME_DIR = darwinRuntimeDirFallback;
  };

  home.activation.ensureXdgRuntimeDir = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      xdg_runtime_dir="${darwinRuntimeDirFallback}"
      run mkdir -p "$xdg_runtime_dir"
      run chmod 700 "$xdg_runtime_dir"
    ''
  );
}
