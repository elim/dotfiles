# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

export UNAME=$(uname)

### Cygwin 1.7
case ${UNAME} in
  CYGWIN*)
    unset nodosfilewarning
    ;;
esac

# zsh の個人用設定ファイルの位置を指定
if [ -z ${ZDOTDIR} ]; then
  export ZDOTDIR=${HOME}
fi
 
# 切り分けた設定ファイルを読み込むディレクトリを指定
export ZUSERDIR=${ZDOTDIR}/.zshrc.d