#!/bin/sh
# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id: .screenrc 110 2006-12-20 15:42:18Z takeru $

DOTDIR=~/dot.files

cd ${DOTDIR}

### xsession
ln -vsf .xsession .xinitrc

### screenrc
SCREENRC_HOST_SPECIFIC_FILE=.screenrc.$(hostname)
SCREENRC_SPECIFIC_FILENAME=.screenrc.specific

rm -f ${DOTDIR}/${SCREENRC_SPECIFIC_FILENAME}

if [ -f ${SCREENRC_HOST_SPECIFIC_FILE} ]; then
    cp -v ${SCREENRC_HOST_SPECIFIC_FILE} ${SCREENRC_SPECIFIC_FILENAME}
else
    touch ${SCREENRC_SPECIFIC_FILENAME}
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

