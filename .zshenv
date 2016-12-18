# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

setopt no_global_rcs

export uname=$(uname)

### Cygwin 1.7
case ${uname} in
  CYGWIN*)
    unset nodosfilewarning
    ;;
esac


#
# path
#
path=(/usr/games(N-/) ${path})
path=(/Developer/Tools(N-/) ${path})
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) ${path})
path=(/usr/local/MacGPG2/bin(N-/) ${path})
path=(/Applications/Emacs.app/Contents/MacOS(N-/) ${path})
path=(/Applications/Emacs.app/Contents/MacOS/bin(N-/) ${path})
path=(~/Applications/Emacs.app/Contents/MacOS(N-/) ${path})
path=(~/Applications/Emacs.app/Contents/MacOS/bin(N-/) ${path})
path=(${HOME}/.anyenv/bin(N-/) ${path})
path=(${HOME}/bin(N-/) ${path})


#
# fpath
#
fpath=(/usr/local/share/zsh-completions(N-/) $fpath)
fpath=(${_z_user_dir}/completions(N-/) ${fpath})
fpath=(${_z_user_dir}/functions(N-/) ${fpath})


#
# anyenv
#
if type anyenv &> /dev/null; then
  eval "$(anyenv init -)"
  for d in $(command ls ~/.anyenv/envs); do
    path=(${HOME}/.anyenv/envs/${d}/shims $path)
  done
fi
