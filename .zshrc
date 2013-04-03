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
# path
#
path=(/usr/games(N-/) ${path})
path=(/Developer/Tools(N-/) ${path})
path=(/opt/local/bin(N-/) /opt/local/sbin(N-/) ${path})
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) ${path})
path=(/usr/local/share/git-core/contrib/workdir(N-/) ${path})
path=(/usr/share/git-core/contrib/workdir(N-/) ${path})
path=(${HOME}/.nodebrew/current/bin(N-/) ${path})
path=(${HOME}/.rbenv/bin(N-/) ${path})
path=(${HOME}/.rbenv/shims(N-/) ${path})
path=(${HOME}/bin(N-/) ${path})

#
# fpath
#
fpath=(${ZUSERDIR}/functions(N-/) ${fpath})

#
# sudo 用の path を設定
#
# - Cygwin には sudo がないので
#   そのまま path に追加
#
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))

case ${UNAME} in
  CYGWIN*)
    path=(${path} ${sudo_path})
    ;;
esac


### LANGUAGE
export LANG=en_US.UTF-8
export LC_CTYPE=ja_JP.UTF-8

### Rubies
if type rbenv &> /dev/null; then
  eval "$(rbenv init -)"
  rbenv global 2.0.0-p0
  alias rehash='rbenv rehash && rehash'
  rehash
fi

### tmux
if [ ${UID} != 0 -a "x${TMUX}" = "x" ]; then
  if type tmux &> /dev/null; then
    if ! (tmux ls | grep 'main' &> /dev/null); then
      exec tmux new-session -s main
    elif ! (tmux ls | grep -E 'main.+attached' &> /dev/null); then
      exec tmux attach-session -t main
    fi
  fi
fi

### Title on Terminal Emulator.
if [ ${TERM} = screen ]; then
  case ${UNAME} in
    CYGWIN*)
      USER=${USERNAME}
      ;;
  esac
  printf "\033P\033]0;${USER}@${HOST}\007\033\\"
fi

### Core Control
case ${UNAME} in
  Darwin|FreeBSD|Linux)
    unlimit
    limit core 0
    limit -s
    ;;
esac

#####################################################################
## 各種設定を include
## （$ZUSERDIR は .zshenv で指定）

for conf in ${ZUSERDIR}/*; do
  source "${conf}"
done

### environment variables
export PAGER=lv
export GZIP='-v9N'
export TZ=JST-9

### CVS
export CVSEDITOR=${EDITOR}
export CVSROOT="${HOME}/var/cvs_db"
export CVS_RSH=ssh

### shell variables
## history
HISTFILE=${ZDOTDIR}/.zhistory         # filename
HISTSIZE=10000                        # メモリ内の履歴の数
SAVEHIST=100000                       # 保存される履歴の数
setopt extended_history               # 履歴ファイルに時刻を記録
setopt inc_append_history             # 履歴をインクリメンタルに追加
setopt share_history                  # 履歴の共有
setopt hist_ignore_all_dups           # ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_dups               # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_space              # スペースで始まるコマンド行はヒストリリストから削除
setopt hist_verify                    # ヒストリを呼び出してから実行する間に一旦編集可能
function history-all { history -E 1 } # 全履歴の一覧を出力する

if [ ${UID} = 0 ]; then               # root のコマンドはヒストリに追加しない
  unset HISTFILE
  SAVEHIST=0
fi

# プロンプトのカラー表示を有効
autoload -U colors
colors

# プロンプト設定
#parameter expansion、command substitute、arthmetic expansionがプロンプト中で行われる。

# http://d.hatena.ne.jp/mollifier/20090814/p1

setopt prompt_subst

for _fpath in $fpath; do
  if [[ -e ${_fpath}/vcs_info ]]; then
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git svn hg bzr
    zstyle ':vcs_info:bzr:*' use-simple true
    zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
    zstyle ':vcs_info:*' formats ' [%b]'
    zstyle ':vcs_info:*' actionformats ' [%b|%a]'

    precmd () {
      psvar=()
      LANG=en_US.UTF-8 vcs_info
      [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
    }
  fi
done
unset _fpath

PROMPT='${WINDOW:+"[$WINDOW]"}[%n@%M]:%c%(#.#.$) '
RPROMPT="[%~%1(v|%F{green}%1v%f|)]"

# ファイル作成時のパーミッション設定
umask 022

# デフォルトの補完機能を有効
autoload -U compinit
### 環境依存
case ${UNAME} in
  CYGWIN*)
    compinit -u
    ;;
  *)
    compinit
    ;;
esac

# 補完の時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*' group-name ''
# 補完候補をカーソル選択
zstyle ':completion:*' menu select=1
# 補完候補に色付け
zstyle ':completion:*' list-colors di=34 fi=0

#####################################################################
# key bindings
#####################################################################

# 端末
# stty erase '^H'
# stty intr '^C'
# stty susp '^Z'

# zsh のキーバインドを emacs 風に
bindkey -e
bindkey "^w" kill-region

# カーソル位置から前方削除
# override kill-whole-line
bindkey '^U' backward-kill-line

# Ctrl + P/N で履歴検索 tcsh風味
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# History completion
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# http://subtech.g.hatena.ne.jp/secondlife/20091124/1259041009
if zle -al |grep history-incremental-pattern-search &> /dev/null; then
  bindkey '^R' history-incremental-pattern-search-backward
  bindkey '^S' history-incremental-pattern-search-forward
fi

# tcsh 風味の単語削除
tcsh-backward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey '^W' tcsh-backward-delete-word

#####################################################################
## 各種設定を include
## （$ZUSERDIR は .zshenv で指定）

for conf in ${ZUSERDIR}/**/*~*_*(.); do
  source "${conf}"
done

if type linux_logo &> /dev/null; then
  case "$(cat /etc/issue)" in
    Debian*)
      linux_logo -L debian
      ;;
    Ubuntu*)
      linux_logo -L ubuntu
      ;;
    *)
      linux_logo -g
  esac
fi

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

case "$TERM" in
  dumb | emacs)
    PROMPT="%m:%~> "
    unsetopt zle
    ;;
esac

#
# Homebrew
#
export HOMEBREW_CURL_VERBOSE=1
export HOMEBREW_VERBOSE=1
export HOMEBREW_DEBUG=1

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
