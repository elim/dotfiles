{ config, pkgs, ... }:
let
  symlink = config.lib.file.mkOutOfStoreSymlink;

  legacies = [
    ".config/fcitx/skk/rule"
    ".config/libskk/rules/MyRule/keymap/default.json"
    ".config/libskk/rules/MyRule/keymap/hankaku-katakana.json"
    ".config/libskk/rules/MyRule/keymap/hiragana.json"
    ".config/libskk/rules/MyRule/keymap/katakana.json"
    ".config/libskk/rules/MyRule/keymap/latin.json"
    ".config/libskk/rules/MyRule/keymap/wide-latin.json"
    ".config/libskk/rules/MyRule/metadata.json"
    ".config/libskk/rules/MyRule/rom-kana/default.json"
    ".config/nixpkgs/config.nix"
    ".config/zsh/config/completion"
    ".config/zsh/config/history"
    ".config/zsh/config/keybind"
    ".config/zsh/config/options"
    ".config/zsh/functions/anyframe-functions/widgets/anyframe-widget-tab-ghq-repository"
    ".config/zsh/functions/figma-url-cleaner"
    ".config/zsh/functions/github-markdown-link-reformatter"
    ".config/zsh/functions/set-copy-paste-command"
    ".config/zsh/functions/tab"
    ".config/zsh/functions/tab.js"
    ".config/zsh/functions/title"
    ".config/zsh/functions/zman"
    ".local/bin/choosy.sh"
    ".local/share/applications/choosy.sh.desktop"
    ".local/share/fcitx5/skk/dictionary_list"
    ".shell.d/environment"
    ".shell.d/lscolors"
    ".shell.d/ulimit"
    ".vimrc"
  ];
in
{
  home.file = builtins.listToAttrs (
    map (path: {
      name = path;
      value = {
        source = "${dotfiles}/home/${config.home.username}/features/legacies/${path}";
      };
    }) legacies
  );
}
