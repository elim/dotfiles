#!/bin/sh

# ----------------------------
# prepare
# ----------------------------

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

# ----------------------------
# functions
# ----------------------------

default_gems() {
  local dotdir=$(dirname $(realpath ${0}))
  local rbenv_dir=$(anyenv root)/envs/rbenv

  mkdir -p ${rbenv_dir}
  ln -fvs ${dotdir}/rbenv/default-gems ${rbenv_dir}
}

simple_link() {
  local dotdir=$(dirname $(realpath ${0}))

  ln -fvs ${dotdir}/.bashrc           ~
  ln -fvs ${dotdir}/.cvsrc            ~
  ln -fvs ${dotdir}/.git.d            ~
  ln -fvs ${dotdir}/.global-gitignore ~
  ln -fvs ${dotdir}/.my.cnf           ~
  ln -fvs ${dotdir}/.sshrc            ~
  ln -fvs ${dotdir}/.sshrc.d          ~
  ln -fvs ${dotdir}/.tmux.conf        ~
  ln -fvs ${dotdir}/.tmux.d           ~
  ln -fvs ${dotdir}/.vimrc            ~
  ln -fvs ${dotdir}/.xsession         ~
  ln -fvs ${dotdir}/.zsh.d            ~
  ln -fvs ${dotdir}/.zshenv           ~
  ln -fvs ${dotdir}/.zshrc            ~
}

# ----------------------------
# main
# ----------------------------

simple_link
default_gems
