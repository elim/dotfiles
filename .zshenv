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
path=(/opt/local/bin(N-/) /opt/local/sbin(N-/) ${path})
path=(/usr/local/bin(N-/) /usr/local/sbin(N-/) ${path})
path=(/usr/local/share/npm/bin(N-/) ${path})
path=(/usr/local/share/git-core/contrib/*(N-/) ${path})
path=(/usr/share/git-core/contrib/*(N-/) ${path})
path=(/usr/share/doc/git/contrib/*(N-/) ${path})
path=(${HOME}/.anyenv/bin(N-/) ${path})
path=(${HOME}/local/bin(N-/) ${HOME}/local/sbin(N-/) ${path})
path=(${HOME}/bin(N-/) ${path})

echo $path > /tmp/envpath

#
# anyenv
#
if type anyenv &> /dev/null; then
  eval "$(anyenv init -)"
  for d in $(command ls ~/.anyenv/envs); do
    path=(${HOME}/.anyenv/envs/${d}/shims $path)
  done
fi
