#http://nyan2.tdiary.net/20020923.html#p12
# zsh の個人用設定ファイルの位置を指定
if [ -z $ZDOTDIR ]; then
  export ZDOTDIR=$HOME
fi
 
# 切り分けた設定ファイルを読み込むディレクトリを指定
export ZUSERDIR=$ZDOTDIR/.zsh

