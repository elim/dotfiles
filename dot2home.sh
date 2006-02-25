#!/bin/sh

DOTDIR=~/dot.files

cd ${DOTDIR}

ln -vsf .x{session,initrc}

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
