#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$

# http://blog.hansode.org/archives/51481467.html
dotdir=$(echo $(cd $(dirname $0) && pwd))

### screenrc
screenrc_d=.screenrc.d
screenrc_local_src=.screenrc.$(hostname)
screenrc_local_dest=.screenrc.local

cd ${dotdir}/${screenrc_d}
rm -f ${screenrc_local_dest}

if [ -f ${screenrc_local_src} ]; then
  ln -sfv  ${screenrc_local_src} ${screenrc_local_dest}
else
  touch ${screenrc_local_dest}
fi

cd ${dotdir}

### xsession
ln -vsf .xsession .xinitrc

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
