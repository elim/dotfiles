#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-

# http://blog.hansode.org/archives/51481467.html
dotdir=$(echo $(cd $(dirname $0) && pwd))

cd ${dotdir}

### xsession
ln -vsf .xsession .xinitrc

### disposition
for f in .*
do
  case ${f} in
    '.'|'..'|'.git'|*~)
      ;;
    *)
      (cd;ln -vsf ${dotdir}/${f} .)
      ;;
  esac
done
