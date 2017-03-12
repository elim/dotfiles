# ----------------------------------------------------------
# stty
# ----------------------------------------------------------
stty stop undef

# ----------------------------------------------------------
# Git prompt
# http://qiita.com/varmil/items/9b0aeafa85975474e9b6
# ----------------------------------------------------------

load_git_completion() {
  local libs=(
    /usr/local/etc/bash_completion.d/git-completion.bash
    /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
    /mingw64/share/git/completion/git-completion.bash
  )

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib && return
  done
}
load_git_completion

load_git_prompt() {
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
load_git_prompt

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

HISTTIMEFORMAT='%Y-%m-%d %T '
PROMPT_COMMAND='share_history'  # 上記関数をプロンプト毎に自動実施
shopt -u histappend   # .bash_history追記モードは不要なのでOFFに
export HISTSIZE=9999  # 履歴のMAX保存数を指定

# ----------------------------------------------------------
# Go
# ----------------------------------------------------------

export GOPATH=$HOME

# ----------------------------------------------------------
# Aliases
# ----------------------------------------------------------
load_aliases() {
  local libs=(
    $SSHHOME/.sshrc.d/.zsh.d/config/alias
    ~/.zsh.d/config/alias
  )

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib && return
  done
}
load_aliases
