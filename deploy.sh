#!/bin/sh

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

blacklistcheck() {
  for black in . .. .git; do
    if [ "${1}x" = "${black}x" ];then
      echo 'black'
      return
    fi
  done
  echo 'white'
}

dotdir=$(dirname $(realpath ${0}))
cd ${dotdir}

for f in .*; do
  if [ $(blacklistcheck ${f}) = white ]; then
    ln -sfv $(realpath ${f}) ~
  fi
done
