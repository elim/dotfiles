#!/bin/sh

# --------------------------------------
# Declare functions
# --------------------------------------

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

vcs_link() {
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

  local rbenv_dir=$(anyenv root)/envs/rbenv
  mkdir -p ${rbenv_dir}
  ln -fvs ${dotdir}/rbenv/default-gems ${rbenv_dir}

}

# --------------------------------------
# Main
# --------------------------------------

vcs_link

mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/shell
touch ~/.gitconfig-credential

if [ -d private ]; then
  cd private
  sh deploy.sh
fi
