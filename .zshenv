# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

export uname=$(uname)

### Cygwin 1.7
case ${uname} in
  CYGWIN*)
    unset nodosfilewarning
    ;;
esac
