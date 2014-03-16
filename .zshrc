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
path=(${HOME}/bin(N-/) ${path})


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
autoload -Uz zman


#
# ruby
#
if type rbenv &> /dev/null; then
  eval "$(rbenv init -)"
  alias rehash='rbenv rehash && rehash'
  rehash
fi
autoload -Uz title


#
# tmux
#
if [ ${UID} != 0 -a "x${TMUX}" = "x" ]; then
  if type tmux &> /dev/null; then
    if ! (tmux ls | grep 'main' &> /dev/null); then
      title main && exec tmux new-session -D -s main
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

if type fortune &> /dev/null; then
  fortune
fi

#
# z
#
export _Z_NO_RESOLVE_SYMLINKS=1
export _Z_NO_COMPLETE_CD=1
z_sh=~/src/z/z.sh
[[ -f ${z_sh} ]] && source ${z_sh}

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
