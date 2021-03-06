export XDG_CONFIG_HOME=~/.config

# ----------------------------------------------------------
# stty
# ----------------------------------------------------------
stty stop undef
bind '"\C-l": unix-filename-rubout'

# ----------------------------------------------------------
# Git prompt
# http://qiita.com/varmil/items/9b0aeafa85975474e9b6
# ----------------------------------------------------------

__load_git_completion() {
  unset -f ${FUNCNAME[0]}

  local libs=(
    /usr/local/etc/bash_completion.d/git-completion.bash
    /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
    /mingw64/share/git/completion/git-completion.bash
  )

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib && return
  done
}
__load_git_completion

__load_git_prompt() {
  unset -f ${FUNCNAME[0]}

  local libs=(
    /usr/local/etc/bash_completion.d/git-prompt.sh
    /usr/share/git-core/contrib/completion/git-prompt.sh
    /etc/bash_completion.d/git-prompt
    /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
    /mingw64/share/git/completion/git-prompt.sh
  )

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib && return
  done
}
__load_git_prompt

# プロンプトに各種情報を表示
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM="verbose"
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWSTASHSTATE=1

############### ターミナルのコマンド受付状態の表示変更
# \u ユーザ名
# \h ホスト名
# \W カレントディレクトリ
# \w カレントディレクトリのパス
# \n 改行
# \d 日付
# \[ 表示させない文字列の開始
# \] 表示させない文字列の終了
# \$ $

if ! type __git_ps1 &> /dev/null; then
  __git_ps1() {
    echo ''
  }
fi

export PS1='\[\033[1;32m\]\u@\h\[\033[00m\]:\[\033[1;34m\]\w\[\033[1;31m\]$(__git_ps1)\[\033[00m\] \$ '

alias sudo='PS1="[\\u@\h \\W]\\$ " sudo'
##############

# ----------------------------------------------------------
# 履歴の共有
# http://qiita.com/nagane/items/f45fcc85b4864fca3909
# ----------------------------------------------------------

function share_history {  # 以下の内容を関数として定義
  history -a  # .bash_historyに前回コマンドを1行追記
  history -c  # 端末ローカルの履歴を一旦消去
  history -r  # .bash_historyから履歴を読み込み直す
}

PROMPT_COMMAND='share_history'  # 上記関数をプロンプト毎に自動実施
shopt -u histappend   # .bash_history追記モードは不要なのでOFFに
export HISTSIZE=9999  # 履歴のMAX保存数を指定
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%Y-%m-%d %T%z '

# ----------------------------------------------------------
# Settings of the detach keys on Docker
# ----------------------------------------------------------
if [[ "${SSHHOME}" ]] &&
     type python &> /dev/null &&
     type docker &> /dev/null; then
  $SSHHOME/.sshrc.d/docker_set_detach_keys.py
fi

# ----------------------------------------------------------
# Go
# ----------------------------------------------------------

export GOPATH=$HOME

# ----------------------------------------------------------
# Aliases
# ----------------------------------------------------------
__load_config() {
  unset -f ${FUNCNAME[0]}

  local base

  [[ -n "$SSHHOME" ]] && base=$SSHHOME/.sshrc.d || base=$HOME

  for conf in ${base}/.shell.d/*; do
    source "${conf}"
  done
}
__load_config
