# -*- shell-script -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

### PATH
# 個人用の PATH を追加
case `uname` in 
    Darwin)
	export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
	if [ -f /sw/bin/init.sh ]; then
	    source /sw/bin/init.sh
	fi
	;;
esac
export PATH="${HOME}/bin:/usr/games:${PATH}"
# 重複を許可しない
typeset -U path PATH
typeset -U fpath

### environment variables
# 共通する環境変数を設定

export G_BROKEN_FILENAMES=1
export EDITOR=vi
export GZIP='-v9N'
export TZ=JST-9

case `uname` in 
    FreeBSD|Linux|Darwin)
	export PAGER=lv
	export LANG=ja_JP.UTF-8
	;;
    CYGWIN*)
	export PAGER='lv -Os'
	export LANG=ja_JP.SJIS
	;;
esac

export LC_MESSAGES=C
export LC_TIME=C
### for CVS
export CVSEDITOR=$EDITOR
export CVSROOT="${HOME}/CVS_DB"
export CVS_RSH=ssh

### shell variables
# ヒストリ設定
HISTFILE=$ZDOTDIR/.zhistory           # ヒストリ保存ファイル
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
 
if [ $UID = 0 ]; then                 # root のコマンドはヒストリに追加しない
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
case `expr \`uname\` : '\(CYGWIN\).*'` in
    CYGWIN)
    compinit -u;;
    *)
    compinit;;
esac


# 補完の時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
 
#####################################################################
# key bindings
#####################################################################
 
# 端末
# stty erase '^H'
# stty intr '^C'
# stty susp '^Z'
 
# zsh のキーバインドを emacs 風に
bindkey -e
 
# カーソル位置から前方削除
# override kill-whole-line
bindkey '^U' backward-kill-line
 
# Ctrl + P/N で履歴検索 tcsh風味
# History completion
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
 
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
 
### zsh options
if [ -f $ZUSERDIR/options ]; then
    source $ZUSERDIR/options
fi
 
### functions
if [ -f $ZUSERDIR/functions ]; then
    source $ZUSERDIR/functions
fi
 
### aliases
if [ -f $ZUSERDIR/aliases ]; then
    source $ZUSERDIR/aliases
fi
 
### completion
if [ -f $ZUSERDIR/completion ]; then
    source $ZUSERDIR/completion
fi
 
### color ls
if [ -f $ZUSERDIR/lscolors ]; then
    source $ZUSERDIR/lscolors
fi


### 環境依存
# core 抑制
# ついでに linux_logo
case `uname` in
    Linux)
	unlimit
	limit core 0
	limit -s

	echo -e '\n'
	if [ -x /usr/bin/linux_logo ]; then
	    linux_logo -a
	fi
	echo -e '\n'
	;;
esac

if [ -x /usr/bin/fortune ]; then
    fortune
fi

