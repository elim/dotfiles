#!/bin/sh

export UNAME=$(uname)

### PATH
case ${UNAME} in 
    Darwin)
	if [ -d /Developer/Tools ];then
	    PATH="/Developer/Tools:${PATH}"
	fi
	if [ -f /sw/bin/init.sh ]; then
	    source /sw/bin/init.sh
	fi
	if [ -d /opt/local/bin ]; then
	    PATH="/opt/local/bin:/opt/local/sbin/:${PATH}"
	fi
	;;
esac
PATH="${HOME}/bin:/usr/games:/usr/local/bin:/usr/local/sbin:${PATH}"
export PATH

if type zsh &> /dev/null; then
	exec zsh -l
fi
