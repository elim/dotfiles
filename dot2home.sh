#!/bin/sh

DOTDIR=~/dot.files

cd ${DOTDIR}

chmod 0710 .fetchmailrc

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

case `uname` in
    CYGWIN*)
	for FILE in ".wl" ".skk"
	do rm -vf ~/${FILE}
	    echo "(load (expand-file-name "~/dot.files/${FILE}"))" > ~/$FILE
	done
	;;
esac
