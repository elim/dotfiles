#!/bin/bash -eu

# ----------------------------
# functions
# ----------------------------

dot_dir() {
  dirname "$(realpath "${0}")"
}

realpath() {
  echo $(cd $(dirname ${1}) && pwd)/$(basename $1)
}

setup-anyenv() {
  local anyenv_dir
  anyenv_dir=~/.anyenv

  if   type anyenv &> /dev/null; then return; fi
  if ! type git    &> /dev/null; then return; fi

  git clone https://github.com/riywo/anyenv.git "${anyenv_dir}"
  cd "$_"

  export PATH="${anyenv_dir}/bin:$PATH"
  eval "$(anyenv init -)"

  git clone https://github.com/znz/anyenv-update.git plugins/anyenv-update

  anyenv install ndenv

  anyenv install pyenv
  git clone https://github.com/yyuu/pyenv-virtualenv envs/pyenv/plugins/pyenv-virtualenv

  anyenv install rbenv
  git clone https://github.com/rbenv/rbenv-default-gems.git envs/rbenv/plugins/rbenv-default-gems
  ln -fvs "${dot_dir}"/rbenv/default-gems envs/rbenv/
}

simply-link() {
  ln -fvs "${dot_dir}"/.bashrc      ~
  ln -fvs "${dot_dir}"/.cvsrc       ~
  ln -fvs "${dot_dir}"/.gitconfig   ~
  ln -fvs "${dot_dir}"/.git.d       ~
  ln -fvs "${dot_dir}"/.hammerspoon ~
  ln -fvs "${dot_dir}"/.my.cnf      ~
  ln -fvs "${dot_dir}"/.sshrc       ~
  ln -fvs "${dot_dir}"/.sshrc.d     ~
  ln -fvs "${dot_dir}"/.tmux.conf   ~
  ln -fvs "${dot_dir}"/.tmux.d      ~
  ln -fvs "${dot_dir}"/.vimrc       ~
  ln -fvs "${dot_dir}"/.xsession    ~
  ln -fvs "${dot_dir}"/.zsh.d       ~
  ln -fvs "${dot_dir}"/.zshenv      ~
  ln -fvs "${dot_dir}"/.zshrc       ~
}

xdg-config() {
  local config_dir
  config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
  mkdir -p "${config_dir}"

  cd "${dot_dir}"/.config
  find . -type d -exec mkdir -p "${config_dir}/{}" \;
  find . -type f -exec ln -fvs "${dot_dir}"/.config/{} "${config_dir}"/{} \;
}

# ----------------------------
# main
# ----------------------------

dot_dir=$(dot_dir)

simply-link
setup-anyenv
xdg-config
