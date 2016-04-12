#
# based on
# - http://namazu.org/%7Esatoru/unimag/3/
# - http://yonchu.hatenablog.com/entry/20120415/1334506855


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
# variable
#
_z_user_dir=~/.zsh.d


#
# path
#
path=(/usr/games(N-/) ${path})
path=(/Developer/Tools(N-/) ${path})
path=(/opt/local/bin(N-/) /opt/local/sbin(N-/) ${path})
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) ${path})
path=(/usr/local/share/npm/bin(N-/) ${path})
path=(/usr/local/share/git-core/contrib/*(N-/) ${path})
path=(/usr/share/git-core/contrib/*(N-/) ${path})
path=(/usr/share/doc/git/contrib/*(N-/) ${path})
path=(${HOME}/.composer/vendor/bin(N-/) ${path})
path=(${HOME}/.nodebrew/current/bin(N-/) ${path})
path=(${HOME}/.rbenv/bin(N-/) ${path})
path=(${HOME}/.rbenv/shims(N-/) ${path})
path=(${HOME}/.pyenv/bin(N-/) ${path})
path=(${HOME}/.pyenv/shims(N-/) ${path})
path=(${HOME}/local/bin(N-/) ${HOME}/local/sbin(N-/) ${path})
path=(${HOME}/bin(N-/) ${path})


#
# コマンドパスを自動で通し npm install -g しない
# http://qiita.com/Jxck_/items/8f5d1b70b7b5aa6053ee
#
export PATH=$PATH:./node_modules/.bin


#
# fpath
#
fpath=(/usr/local/share/zsh-completions $fpath)
fpath=(${_z_user_dir}/completions(N-/) ${fpath})
fpath=(${_z_user_dir}/functions(N-/) ${fpath})


#
# sudo 用の path を設定
#
# - Cygwin には sudo がないので
#   そのまま path に追加
#
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))

case ${uname} in
  CYGWIN*)
    path=(${path} ${sudo_path})
    ;;
esac


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
autoload -Uz bbpr
autoload -Uz tab
autoload -Uz title
autoload -Uz tmux-grunt-serve
autoload -Uz tmux-docker-compose
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
for conf in ${_z_user_dir}/config/*; do
  source "${conf}"
done


# ファイル作成時のパーミッション設定
umask 022

# zsh のキーバインドを emacs 風に


if type keychain &> /dev/null; then
  keychain --nogui --noask ${HOME}/.ssh/id_rsa
  source ${HOME}/.keychain/$(hostname)-sh
fi


#
# gpg2
# https://www.insaneworks.co.jp/kota/git%E3%81%A7%E7%BD%B2%E5%90%8D%E4%BB%98%E3%81%8Dcommits%E3%82%84tag%E3%82%92%E4%BD%9C%E3%82%8B/
#
pgrep -q gpg-agent || eval $(gpg-agent --daemon --write-env-file ${HOME}/.gpg-agent-info)
[ -f ${HOME}/.gpg-agent-info ] && source ${HOME}/.gpg-agent-info
export GPG_AGENT_INFO
export GPG_TTY=`tty`


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
# ruby
#
if type rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
  alias rehash='rbenv rehash && rehash'
  rehash
fi


#
# python
#
if type pyenv &> /dev/null; then
    eval "$(pyenv init -)";
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
fpath=($HOME/src/github.com/mollifier/anyframe(N-/) $fpath)
fpath=(${_z_user_dir}(N-/) ${fpath})

autoload -Uz anyframe-init
anyframe-init

bindkey '^xb'  anyframe-widget-cdr
bindkey '^x^b' anyframe-widget-checkout-git-branch

bindkey '^xr'  anyframe-widget-execute-history
bindkey '^x^r' anyframe-widget-execute-history

bindkey '^xp'  anyframe-widget-put-history
bindkey '^x^p' anyframe-widget-put-history

bindkey '^xs'  anyframe-widget-cd-ghq-repository
bindkey '^x^s' anyframe-widget-cd-ghq-repository

bindkey '^xt'  anyframe-widget-tab-ghq-repository
bindkey '^x^t' anyframe-widget-tab-ghq-repository

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

# Local Variables:
# mode: shell-script
# coding: utf-8-unix
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
