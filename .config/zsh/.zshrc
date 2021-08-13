#
# based on
# - http://namazu.org/%7Esatoru/unimag/3/
# - http://yonchu.hatenablog.com/entry/20120415/1334506855

#
# zinit
#
() {
  ### Added by Zinit's installer
  if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
      print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
  fi

  source "$HOME/.zinit/bin/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # Load a few important annexes, without Turbo
  # (this is currently required for annexes)
  zinit light-mode for \
        zinit-zsh/z-a-patch-dl \
        zinit-zsh/z-a-as-monitor \
        zinit-zsh/z-a-bin-gem-node

  ### End of Zinit's installer chunk

  zinit ice wait'!'; zinit light mollifier/anyframe
  zinit ice wait'!'; zinit light mollifier/cd-gitroot
  zinit ice wait'!'; zinit light spwhitt/nix-zsh-completions
  zinit ice wait'!'; zinit light zsh-users/zsh-completions
  zinit ice wait'!'; zinit light zsh-users/zsh-syntax-highlighting
}


#
# note:
#
#   typeset
#    -U 重複パスを登録しない
#    -x exportも同時に行う
#    -T 環境変数へ紐付け
#
#   path=xxxx(N-/)
#     (N-/): 存在しないディレクトリは登録しない
#     パス(...): ...という条件にマッチするパスのみ残す
#        N: NULL_GLOBオプションを設定。
#           globがマッチしなかったり存在しないパスを無視する
#        -: シンボリックリンク先のパスを評価
#        /: ディレクトリのみ残す
#        .: 通常のファイルのみ残す


#
# sudo 用の path を設定
#
# - Cygwin には sudo がないので
#   そのまま path に追加
#
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))


#
# GOPATH
#
export GOPATH=$HOME


#
# locale
#
export LANG=en_US.UTF-8
export LC_CTYPE=ja_JP.UTF-8


#
# autoloads
#
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz is-at-least


#
# shell functions
#
autoload -Uz figma-url-cleaner
autoload -Uz github-markdown-link-reformatter
autoload -Uz tab
autoload -Uz title
autoload -Uz zman


#
# tmux
#
zinit snippet "${ZDOTDIR}/snippets/tmux"


#
# load configuration
#

for conf in ~/.shell.d/* ${ZDOTDIR}/config/*; do
  source "${conf}"
done


# ファイル作成時のパーミッション設定
umask 022

# Reuse the ssh-agent on the tmux even if ForwardAgent is
# enabled.
# https://qiita.com/sonots/items/2d7950a68da0a02ba7e4
() {
  local agent="$HOME/.ssh/agent"

  if [ -S "$SSH_AUTH_SOCK" ]; then
    case $SSH_AUTH_SOCK in
      /tmp/*/agent.[0-9]*)
        ln -snf "$SSH_AUTH_SOCK" $agent &&
          export SSH_AUTH_SOCK=$agent
    esac
  elif [ -S $agent ]; then
    export SSH_AUTH_SOCK=$agent
  else
    echo "no ssh-agent"
  fi
}

zinit ice wait '!'; zinit snippet "${ZDOTDIR}/snippets/keychain"

GPG_TTY=$(tty)
export GPG_TTY

(( $+commands[fortune] )) && fortune


#
# cdr
# http://blog.n-z.jp/blog/2013-11-12-zsh-cdr.html
#
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':completion:*:*:cdr:*:*' menu selection
  zstyle ':completion:*' recent-dirs-insert both
  zstyle ':chpwd:*' recent-dirs-max 500
  zstyle ':chpwd:*' recent-dirs-default true
  zstyle ':chpwd:*' recent-dirs-file "${XDG_CACHE_HOME:-$HOME/.cache}/shell/chpwd-recent-dirs"
  zstyle ':chpwd:*' recent-dirs-pushd true
fi


#
# anyframe
# http://qiita.com/mollifier/items/81b18c012d7841ab33c3
#
fpath=(${ZDOTDIR}(N-/) ${fpath})

autoload -Uz anyframe-init

bindkey '^xb'  anyframe-widget-cdr
bindkey '^x^b' anyframe-widget-checkout-git-branch

bindkey '^xr'  anyframe-widget-execute-history
bindkey '^x^r' anyframe-widget-execute-history

bindkey '^xp'  anyframe-widget-put-history
bindkey '^x^p' anyframe-widget-put-history

bindkey '^xs'  anyframe-widget-cd-ghq-repository
bindkey '^x^s' anyframe-widget-cd-ghq-repository

if [[ ${OSTYPE} =~ '^darwin*' ]]; then
  bindkey '^xt'  anyframe-widget-tab-ghq-repository
  bindkey '^x^t' anyframe-widget-tab-ghq-repository
else
  bindkey '^xt'  anyframe-widget-cd-ghq-repository
  bindkey '^x^t' anyframe-widget-cd-ghq-repository
fi

bindkey '^xk'  anyframe-widget-kill
bindkey '^x^k' anyframe-widget-kill

bindkey '^xi'  anyframe-widget-insert-git-branch
bindkey '^x^i' anyframe-widget-insert-git-branch

bindkey '^xf'  anyframe-widget-insert-filename
bindkey '^x^f' anyframe-widget-insert-filename


#
# $TERM
#
case "${TERM}" in
  dumb | emacs)
    PROMPT="%m:%~> "
    unsetopt zle
    ;;
esac


#
# Remove duplicate paths
#
typeset -U path cdpath fpath manpath


#
# direnv
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"


#
# Show shell profile
#
[[ "${ZPROF}" ]] && zprof

# Local Variables:
# mode: sh
# sh-shell: zsh
# End:
