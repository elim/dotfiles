#!/bin/sh

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

is_in_blacklist() {
  for black in . .. .git .rbenv; do
    if [ "${1}x" = "${black}x" ];then
      echo 'true'
      return
    fi
  done
  echo 'false'
}

dotdir=$(dirname $(realpath ${0}))
cd ${dotdir}

for f in .*; do
  if [ $(is_in_blacklist ${f}) = false ]; then
    ln -sfv $(realpath ${f}) ~
  fi
done

mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/shell

mkdir -p ~/.rbenv
ln -sfv $(realpath .rbenv/default-gems) ~/.rbenv
touch ~/.gitconfig-credential

if [ -d private ]; then
  cd private
  sh deploy.sh
fi


