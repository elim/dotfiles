{
  config,
  lib,
  pkgs,
  ...
}:

let
  reloadHmSessionVars = builtins.readFile (
    pkgs.replaceVars ./reload-hm-session-vars.sh.in {
      hmSessionVarsPath = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    }
  );
in
{
  home.sessionVariables = {
    TZ = "Asia/Tokyo";

    LESS = "--hilite-search --HILITE-UNREAD --ignore-case --LONG-PROMPT --no-init --RAW-CONTROL-CHARS --shift=4 --tabs=4 --quit-if-one-screen";
    PAGER = "less";

    TIME = ''
      Time spent in user mode   (CPU seconds) : %Us
      Time spent in kernel mode (CPU seconds) : %Ss
      Total time                              : %Es
      CPU utilisation (percentage)            : %P
      Times the process was swapped           : %W
      Times of major page faults              : %F
      Times of minor page faults              : %R'';
  };

  programs.bash.bashrcExtra = lib.mkBefore reloadHmSessionVars;
  programs.zsh.envExtra = lib.mkBefore reloadHmSessionVars;
}
