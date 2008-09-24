# -*- mode: shell-script; coding: utf-8-unix -*-
# based on http://namazu.org/%7Esatoru/unimag/3/

### Title on Terminal Emulator.
printf "\033P\033]0;${USER}@${HOST}\007\033\\"

### PATH
case ${UNAME} in 
    Darwin)
	if [ -d /Developer/Tools ]; then
	    PATH="/Developer/Tools:${PATH}"
	fi
	if [ -d /opt/local/bin ]; then
	    PATH="/opt/local/bin:/opt/local/sbin/:${PATH}"
	fi
	;;
esac
PATH="${HOME}/bin:/usr/games:/usr/local/bin:/usr/local/sbin:${PATH}"
export PATH

# 重複を許可しない
typeset -U path PATH
typeset -U fpath

### GNU Screen
if [ ${UID} != 0 -a "x${WINDOW}" = "x" ]; then
  if type screen &> /dev/null; then
    if ! (screen -ls |egrep -i 'main.+(attached|dead)' &> /dev/null); then
      exec screen -DRRS main
    fi
  fi
fi

# core control
case ${UNAME} in
    Darwin|FreeBSD|Linux)
	unlimit
	limit core 0
	limit -s
	;;
esac

### environment variables
if type emacsclient &> /dev/null; then
  export EDITOR='emacsclient --alternate-editor=vi'
else
  export EDITOR=vi
fi
export PAGER=lv
export GZIP='-v9N'
export TZ=JST-9

case ${UNAME} in 
    FreeBSD|Linux|Darwin)
	export LANG=en_US.UTF-8
	export LC_CTYPE=ja_JP.UTF-8
	;;
    CYGWIN*)
	export LANG=en_US.UTF-8
	export LC_CTYPE=ja_JP.SJIS
	;;
esac

### for CVS
export CVSEDITOR=${EDITOR}
export CVSROOT="${HOME}/var/cvs_db"
export CVS_RSH=ssh

### shell variables
# ヒストリ設定
HISTFILE=${ZDOTDIR}/.zhistory         # ヒストリ保存ファイル
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
setopt prompt_subst
PROMPT='${WINDOW:+"[$WINDOW]"}[%n@%M]:%c%(#.#.$) '
RPROMPT='[%~]'


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
 
for conf in ${ZUSERDIR}/*; do
  source "${conf}"
done

if type clear &> /dev/null; then
    clear
fi

if type linux_logo &> /dev/null; then
    linux_logo -a
fi

if type keychain &> /dev/null; then
    keychain --nogui ${HOME}/.ssh/id_rsa
    source ${HOME}/.keychain/$(hostname)-sh
fi

if type fortune &> /dev/null; then
    fortune
fi
