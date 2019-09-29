#
# based on
# - http://namazu.org/%7Esatoru/unimag/3/
# - http://yonchu.hatenablog.com/entry/20120415/1334506855

#
# zplugin
#
() {
  if [[ ! -d ${HOME}/.zplugin ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
  fi

  source ${HOME}/.zplugin/bin/zplugin.zsh
  autoload -Uz _zplugin
  (( ${+_comps} )) && _comps[zplugin]=_zplugin

  zplugin ice wait'!'; zplugin light mollifier/anyframe
  zplugin ice wait'!'; zplugin light mollifier/cd-gitroot
  zplugin ice wait'!'; zplugin light zsh-users/zsh-completions
  zplugin ice wait'!'; zplugin light zsh-users/zsh-syntax-highlighting
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
autoload -Uz tab
autoload -Uz title
autoload -Uz zman


#
# tmux
#
if [ ${UID} != 0 -a "x${TMUX}" = "x" ]; then
  if type tmux &> /dev/null; then
    if ! (tmux ls | grep 'main' &> /dev/null); then
      title main && sleep 1 && exec tmux new-session -D -s main
    elif ! (tmux ls | grep -E 'main.+attached' &> /dev/null); then
      exec tmux attach-session -t main
    fi
  fi
fi


#
# load configuration
#
for conf in ${ZDOTDIR}/config/*; do
  source "${conf}"
done


# ファイル作成時のパーミッション設定
umask 022

() {
  local inherit='local-once'
  [[ ${uname} == 'Darwin' ]] && inherit='any'

  if type keychain &> /dev/null; then
    export GPG_AGENT_INFO="~/.gnupg/S.gpg-agent:$(pgrep gpg-agent):1"
    eval $(keychain --inherit ${inherit} --agents 'gpg,ssh' --eval id_ed25519 0A2D3E0E)
  fi
}

GPG_TTY=$(tty)
export GPG_TTY

if type fortune &> /dev/null; then
  fortune
fi


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
# npm
#
if type npm &> /dev/null; then
  source <(npm completion)
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

if [[ ${uname} == 'Darwin' ]]; then
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
# Show shell profile
#
type zprof &> /dev/null && zprof

# Local Variables:
# mode: shell-script
# coding: utf-8-unix
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
