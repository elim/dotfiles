#!/bin/sh

DOTDIR=${HOME}/dot.files/

if [ ${DOTDIR} -ef ${PWD} ]; then
    echo "OK"
else
    echo "NG"
fi



