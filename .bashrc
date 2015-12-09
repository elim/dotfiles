# ----------------------------------------------------------
# Git prompt
# http://qiita.com/varmil/items/9b0aeafa85975474e9b6
# ----------------------------------------------------------

load_git_completion() {
  local libs=(/mingw64/share/git/completion/git-completion.bash /usr/local/etc/bash_completion.d/git-completion.bash)

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib
  done
}
load_git_completion

load_git_prompt() {
  local libs=(/mingw64/share/git/completion/git-prompt.sh /usr/local/etc/bash_completion.d/git-prompt.sh)

  for lib in ${libs[@]}; do
    [[ -f $lib ]] && source $lib
  done
}
load_git_prompt

# プロンプトに各種情報を表示
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM=1
GIT_PS1_SHOWUNTRACKEDFILES=
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
export PS1='\[\033[1;32m\]\u\[\033[00m\]:\[\033[1;34m\]\w\[\033[1;31m\]$(__git_ps1)\[\033[00m\] \$ '
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