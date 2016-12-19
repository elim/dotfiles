#!/bin/sh -eu

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

git_ignore() {
  local dest src
  local d f

  local dotdir=$(dirname $(realpath ${0}))
  local xdg_config_home=${XDG_CONFIG_HOME:-$HOME/.config}

  if [ -d ${xdg_config_home} ]; then
    cd ${dotdir}/.config

    for d in $(find . -type d); do
      mkdir -p $(realpath ${xdg_config_home}/${d})
    done

    for f in $(find . -type f); do
      src=$(realpath ${dotdir}/.config/${f})
      dest=$(realpath ${xdg_config_home}/${f})

      ln -fvs ${src} ${dest}
    done
  fi
}

simple_link() {
  local dotdir=$(dirname $(realpath ${0}))

  ln -fvs ${dotdir}/.bashrc      ~
  ln -fvs ${dotdir}/.cvsrc       ~
  ln -fvs ${dotdir}/.git.d       ~
  ln -fvs ${dotdir}/.hammerspoon ~
  ln -fvs ${dotdir}/.my.cnf      ~
  ln -fvs ${dotdir}/.sshrc       ~
  ln -fvs ${dotdir}/.sshrc.d     ~
  ln -fvs ${dotdir}/.tmux.conf   ~
  ln -fvs ${dotdir}/.tmux.d      ~
  ln -fvs ${dotdir}/.vimrc       ~
  ln -fvs ${dotdir}/.xsession    ~
  ln -fvs ${dotdir}/.zsh.d       ~
  ln -fvs ${dotdir}/.zshenv      ~
  ln -fvs ${dotdir}/.zshrc       ~
}

# ----------------------------
# main
# ----------------------------

simple_link
default_gems
git_ignore
