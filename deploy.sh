#!/bin/sh

function realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

function blacklistcheck() {
  for black in . .. .git .gitignore; do
    if [ "${1}x" = "${black}x" ];then
      echo 'black'
      return
    fi
  done
  echo 'white'
}

dotdir=$(dirname $(realpath ${0}))
cd $dotdir

for f in .*; do
  if [ $(blacklistcheck ${f}) = white  ]; then
    ln -sfv $(realpath ${f}) ~
  fi
done
