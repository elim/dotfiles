# -*- shell-script -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

### PATH
# �Ŀ��Ѥ� PATH ���ɲ�
case `uname` in 
    Darwin)
	export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
	if [ -f /sw/bin/init.sh ]; then
	    source /sw/bin/init.sh
	fi
	;;
esac
export PATH="${HOME}/bin:/usr/games:${PATH}"
# ��ʣ����Ĥ��ʤ�
typeset -U path PATH
typeset -U fpath

### environment variables
# ���̤���Ķ��ѿ�������

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
# �ҥ��ȥ�����
HISTFILE=$ZDOTDIR/.zhistory           # �ҥ��ȥ���¸�ե�����
HISTSIZE=10000                        # �����������ο�
SAVEHIST=100000                       # ��¸���������ο�
setopt extended_history               # ����ե�����˻����Ͽ
setopt inc_append_history             # ����򥤥󥯥��󥿥���ɲ�
setopt share_history                  # ����ζ�ͭ
setopt hist_ignore_all_dups           # �ҥ��ȥ���ɲä���륳�ޥ�ɹԤ��Ť���Τ�Ʊ���ʤ�Ť���Τ���
setopt hist_ignore_dups               # ľ����Ʊ�����ޥ�ɥ饤��ϥҥ��ȥ���ɲä��ʤ�
setopt hist_ignore_space              # ���ڡ����ǻϤޤ륳�ޥ�ɹԤϥҥ��ȥ�ꥹ�Ȥ�����
setopt hist_verify                    # �ҥ��ȥ��ƤӽФ��Ƥ���¹Ԥ���֤˰�ö�Խ���ǽ
function history-all { history -E 1 } # ������ΰ�������Ϥ���
 
if [ $UID = 0 ]; then                 # root �Υ��ޥ�ɤϥҥ��ȥ���ɲä��ʤ�
    unset HISTFILE
    SAVEHIST=0
fi
 
# �ץ��ץȤΥ��顼ɽ����ͭ��
autoload -U colors
colors
 
# �ץ��ץ�����
#parameter expansion��command substitute��arthmetic expansion���ץ��ץ���ǹԤ��롣
setopt prompt_subst
PROMPT='${WINDOW:+"[$WINDOW]"}[%n@%M]:%c%(#.#.$) '
RPROMPT='[%~]'


# �ե�����������Υѡ��ߥå��������
umask 022
 
# �ǥե���Ȥ��䴰��ǽ��ͭ��
autoload -U compinit
### �Ķ���¸
case `expr \`uname\` : '\(CYGWIN\).*'` in
    CYGWIN)
    compinit -u;;
    *)
    compinit;;
esac


# �䴰�λ�����ʸ����ʸ������̤��ʤ�
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
 
#####################################################################
# key bindings
#####################################################################
 
# ü��
# stty erase '^H'
# stty intr '^C'
# stty susp '^Z'
 
# zsh �Υ����Х���ɤ� emacs ����
bindkey -e
 
# ����������֤����������
# override kill-whole-line
bindkey '^U' backward-kill-line
 
# Ctrl + P/N �����򸡺� tcsh��̣
# History completion
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
 
# tcsh ��̣��ñ����
tcsh-backward-delete-word () {
    local WORDCHARS="${WORDCHARS:s#/#}"
    zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey '^W' tcsh-backward-delete-word
 
#####################################################################
## �Ƽ������ include
## ��$ZUSERDIR �� .zshenv �ǻ����
 
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


### �Ķ���¸
# core ����
# �Ĥ��Ǥ� linux_logo
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

