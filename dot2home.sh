#!/bin/zsh

DOTDIR=${HOME}/dot.files/

for FILE in ${DOTDIR}/e
  do ls -lha ${FILE}
done

if [ ${DOTDIR} -ef ${PWD} ]; then
    echo "OK"
else
    echo "NG"
fi



