{ pkgs, ... }:
{
  home.packages = [ pkgs.git-wt ];

  # Place worktrees inside .git/wt to avoid tools (e.g., linters, Claude Code)
  # traversing worktree directories, since most tools ignore .git/.
  programs.git.settings.wt.basedir = ".git/wt";

  # Enable shell integration: zsh completion + git() wrapper for auto-cd.
  # `git wt <TAB>` lists existing worktrees; selecting one switches to it.
  programs.zsh.initContent = ''
    eval "$(git wt --init zsh)"
  '';
}
