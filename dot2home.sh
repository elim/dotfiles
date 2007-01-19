#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id: .screenrc 110 2006-12-20 15:42:18Z takeru $

DOTDIR=${HOME}/dot.files

cd ${DOTDIR}

### xsession
ln -vsf .xsession .xinitrc

### screenrc
SPECIFIC_SCREENRC_SRC=.screenrc.$(hostname)
SPECIFIC_SCREENRC_DEST=.screenrc.specific

rm -f ${DOTDIR}/${SPECIFIC_SCREENRC_DEST}

if [ -f ${SPECIFIC_SCREENRC_SRC} ]; then
    cp -v ${SPECIFIC_SCREENRC_SRC} ${SPECIFIC_SCREENRC_DEST}
else
    touch ${SPECIFIC_SCREENRC_DEST}
fi
    
### disposition
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

