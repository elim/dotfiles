#!/bin/bash -eu

bold=$(tput bold)
normal=$(tput sgr0)

# ----------------------------
# functions
# ----------------------------

delete-bloken-links() {
  right-here

  find ~                    -maxdepth 1 -type l -follow -print0 |xargs -0 rm -v
  find "$(xdg-config-path)"             -type l -follow -print0 |xargs -0 rm -v
}

dot_dir() {
  dirname "$(realpath "${0}")"
}

right-here() {
  echo; echo "${bold}${FUNCNAME[1]}${normal}"; echo
}

realpath() {
  echo "$(cd "$(dirname "${1}")" && pwd)/$(basename "${1}")"
}

setup-anyenv() {
  right-here

  local anyenv_dir
  anyenv_dir=~/.anyenv

  if   type anyenv &> /dev/null; then return; fi
  if ! type git    &> /dev/null; then return; fi

  git clone https://github.com/riywo/anyenv.git "${anyenv_dir}"
  cd "$_"

  export PATH="${anyenv_dir}/bin:$PATH"
  eval "$(anyenv init -)"

  git clone https://github.com/znz/anyenv-update.git plugins/anyenv-update

  anyenv install nodenv
  git clone https://github.com/nodenv/nodenv-package-rehash.git "$(nodenv root)"/plugins/nodenv-package-rehash
  ln -fvs "${dot_dir}"/nodenv/default-packages envs/nodenv/

  anyenv install pyenv
  git clone https://github.com/yyuu/pyenv-virtualenv "$(pyenv root)"/plugins/pyenv-virtualenv

  anyenv install rbenv
  git clone https://github.com/rbenv/rbenv-default-gems.git "$(rbenv root)"/plugins/rbenv-default-gems
  ln -fvs "${dot_dir}"/rbenv/default-gems envs/rbenv/
}

simply-link() {
  right-here

  ln -fvs "${dot_dir}"/.bashrc    ~
  ln -fvs "${dot_dir}"/.shell.d   ~
  ln -fvs "${dot_dir}"/.sshrc     ~
  ln -fvs "${dot_dir}"/.sshrc.d   ~
  ln -fvs "${dot_dir}"/.tmux.conf ~
  ln -fvs "${dot_dir}"/.tmux.d    ~
  ln -fvs "${dot_dir}"/.vimrc     ~
  ln -fvs "${dot_dir}"/.zshenv    ~

  find ~ -maxdepth 1 -type l -follow -print0 |xargs -0 rm -v
}

xdg-config-path() {
  local config_dir
  echo "${XDG_CONFIG_HOME:-$HOME/.config}"
}

xdg-config() {
  right-here

  local config_dir
  config_dir=$(xdg-config-path)

  mkdir -p "${config_dir}"
  (
    cd "${dot_dir}"/.config

    find . -type d -exec mkdir -p "${config_dir}/{}" \;
    find . -type f -exec ln -fvs "${dot_dir}"/.config/{} "${config_dir}"/{} \;
  )
}

# ----------------------------
# main
# ----------------------------

dot_dir=$(dot_dir)

simply-link
setup-anyenv
xdg-config
delete-bloken-links
