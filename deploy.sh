#!/bin/sh

# --------------------------------------
# Declare functions
# --------------------------------------

is_in_blacklist() {
  for black in . .. .git .rbenv; do
    if [ "${1}x" = "${black}x" ];then
      echo 'true'
      return
    fi
  done
  echo 'false'
}

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

zhistory_cloud_link() {
  local cloud_dir=~/Dropbox
  local src=${cloud_dir}/__core__/zsh_history
  local dest=~/.zhistory

  if [ -f ${src} -a ! -f ${dest} ]; then
    ln -v ${src} ${dest}
  fi
}

# --------------------------------------
# Main
# --------------------------------------

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

zhistory_cloud_link

if [ -d private ]; then
  cd private
  sh deploy.sh
fi
