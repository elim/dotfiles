# -*- shell-script -*-
PATH="$HOME/bin:$PATH"
#xset +fp ~/lib/X11/fonts
#xset fp rehash
#xset m speed Threshold
#xset m 2 5
xset r rate 240 100

LANG=ja_JP.eucJP
export LANG

LC_ALL=ja_JP.eucJP
export LC_ALL

XMODIFIERS=@im=skkinput
export XMODIFIERS

G_BROKEN_FILENAMES=1
export G_BROKEN_FILENAMES

#GDK_USE_XFT=0
#export GDK_USE_XFT

/bin/rm /tmp/.ICE-unix/*
/bin/rm $HOME/.DCOPserver*

#if [ -f $HOME/.xmodmap.winkey ]; then
#    xmodmap $HOME/.xmodmap.winkey&
#fi

echo ${SSH_AUTH_SOCK} > ~/.ssh_auth_sock

#if [ -x /usr/bin/fetchmail ]; then
#    fetchmail&
#fi

if [ -x /usr/bin/X11/skkinput ]; then
    skkinput&
fi

if [ -x /usr/bin/esd ]; then
    esd -nobeeps&
fi

if [ -x /usr/bin/xscreensaver ]; then
    xscreensaver -nosplash&
fi

#if [ -x /usr/bin/knotes ]; then
#    knotes&
#fi

if [ -x /usr/bin/wmcube ]; then
    wmcube&
fi

if [ -x /usr/bin/wmmoonclock ]; then
    wmmoonclock&
fi

if [ -x /usr/bin/wmxmms ]; then
    wmxmms&
fi

if [ -x /usr/bin/wmpuzzle ]; then
    wmpuzzle&
fi

if [ -x /usr/bin/wmtimer ]; then
    wmtimer&
fi

#if [ -x /usr/bin/volume.app ]; then
#    volume.app&
#fi

#ssh-agent の記述を足せ

if [ -x /usr/bin/mlterm ]; then
    if [ -x /usr/bin/screen ]; then
	mlterm --daemon=blend -e screen -xR &
    else
	mlterm --daemon=blend &
    fi
fi

if [ -x /usr/bin/fluxbox ]; then
    fluxbox
fi

#if [ -x /usr/bin/gnome-session ]; then
#    gnome-session
#fi

#if [ -x /usr/bin/X11/twm ]; then
#    twm
#fi
