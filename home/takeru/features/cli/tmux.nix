{
  config,
  pkgs,
  dotfiles,
  ...
}:

let
  legacyTmuxDir = "${dotfiles}/home/${config.home.username}/features/legacies/.tmux.d";
  legacyTmuxConf = "${dotfiles}/home/${config.home.username}/features/legacies/.tmux.conf";
in
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    extraConfig = builtins.readFile legacyTmuxConf;
  };

  home.file = {
    ".tmux.d/linux.conf".source = "${legacyTmuxDir}/linux.conf";
    ".tmux.d/macos.conf".source = "${legacyTmuxDir}/macos.conf";
  };
}
