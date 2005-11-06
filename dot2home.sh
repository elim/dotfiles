#!/bin/sh

DOTDIR=~/dot.files

cd ${DOTDIR}

chmod 0710 .fetchmailrc

for FILE in .*
  do
    if [ ${FILE} != "." -a ${FILE} != ".." -a ${FILE} != ".svn" ]; then
	(cd;ln -sfv ${DOTDIR}/${FILE} .)
    fi
done

case `uname` in
    CYGWIN*)
	rm -f ~/.wl
	echo '(load (expand-file-name "~/dot.files/.wl"))' > ~/.wl
	;;
esac
