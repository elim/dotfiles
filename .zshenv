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
