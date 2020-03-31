# based on http://nyan2.tdiary.net/20020923.html#p12

setopt no_global_rcs

[[ "${ZPROF}" ]] && zmodload zsh/zprof && zprof

export XDG_CONFIG_HOME=~/.config
ZDOTDIR=${XDG_CONFIG_HOME}/zsh

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

# Homebrew Shell Completion
# https://docs.brew.sh/Shell-Completion
if (( $+commands[brew] )); then
  fpath=($(brew --prefix)/share/zsh/site-functions $fpath)

  autoload -Uz compinit
  compinit
fi

#
# anyenv
#
if (( $+commands[anyenv] )); then
  eval "$(anyenv init -)"
  for d in $(command ls ~/.anyenv/envs); do
    path=(${HOME}/.anyenv/envs/${d}/shims $path)
  done
fi

# Local Variables:
# mode: sh
# sh-shell: zsh
# End:
