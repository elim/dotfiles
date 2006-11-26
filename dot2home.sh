#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-

DOTDIR=~/dot.files

cd ${DOTDIR}

ln -vsf .xsession .xinitrc

for FILE in .*
do
    case ${FILE} in
	'.'|'..'|'.svn'|*~)
	    ;;
	*)
	    (cd;ln -vsf ${DOTDIR}/${FILE} .)
	    ;;
    esac
done
