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
	rm -vf ~/.wl
	echo '(load (expand-file-name "~/dot.files/.wl"))' |tee ~/.wl
	rm -vf ~/.skk
	echo '(load (expand-file-name "~/dot.files/.skk"))' |tee ~/.skk
	;;
esac
