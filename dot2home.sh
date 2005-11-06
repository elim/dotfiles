#!/bin/sh

DOTDIR=~/dot.files

cd ${DOTDIR}

chmod 0710 .fetchmailrc

for FILE in .*
  do
    if [ ${FILE} != "." -a ${FILE} != ".." -a ${FILE} != ".svn" ]; then
	(cd;ln -vsf ${DOTDIR}/${FILE} .)
    fi
done

case `uname` in
    CYGWIN*)
	for FILE in ".wl" ".skk"
	do rm -vf ~/${FILE}
	    echo "(load (expand-file-name "~/dot.files/${FILE}"))" > ~/$FILE
	done
	;;
esac
