#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$

# http://blog.hansode.org/archives/51481467.html
dotdir=$(echo $(cd $(dirname $0) && pwd))
cd ${dotdir}

### emacs
rm -f .emacs
if type emacs &> /dev/null; then 
  if  emacs --version |grep '\(19\|20\|21\)\.'; then
    echo '(load (expand-file-name "~/.emacs.d/init.el"))' > .emacs
  fi
fi

### xsession
ln -vsf .xsession .xinitrc

### screenrc
screenrc_d=.screenrc.d
screenrc_local_src=${screenrc_d}/.screenrc.$(hostname)
screenrc_local_dest=${screenrc_d}/.screenrc.local

rm -f ${dotdir}/${screenrc_local_dest}

if [ -f ${screenrc_local_src} ]; then
  ln -sfv  ${screenrc_local_src} ${screenrc_local_dest}
else
  touch ${screenrc_local_dest}
fi

### disposition
for f in .*
do
  case ${f} in
    '.'|'..'|'.svn'|*~)
      ;;
    *)
      (cd;ln -vsf ${dotdir}/${f} .)
      ;;
  esac
done
