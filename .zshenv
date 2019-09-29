# -*- mode: shell-script; coding: utf-8-unix -*-
# $Id$
# based on http://nyan2.tdiary.net/20020923.html#p12

setopt no_global_rcs

[[ "${ZPROF}" ]] && zmodload zsh/zprof && zprof

export uname=$(uname)

ZDOTDIR=~/.zsh.d

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
fpath=(/usr/local/share/zsh/functions(N-/) $fpath)
fpath=(/usr/local/share/zsh-completions(N-/) $fpath)
fpath=(${ZDOTDIR}/completions(N-/) ${fpath})
fpath=(${ZDOTDIR}/functions(N-/) ${fpath})


#
# anyenv
#
if type anyenv &> /dev/null; then
  eval "$(anyenv init -)"
  for d in $(command ls ~/.anyenv/envs); do
    path=(${HOME}/.anyenv/envs/${d}/shims $path)
  done
fi
