# -*- shell-script -*-
PATH="${HOME}/bin:${PATH}"
#xset +fp ${HOME}/lib/X11/fonts
#xset fp rehash
#xset m speed Threshold
# 加速値 == マウスの動きを指定した数値倍だけ速くする。
# 閾値 == 指定したピクセル数だけマウスポインタが移動したときに加速値が有効になる
xset m 1 20 # for Marble Mouse
xmodmap -e "pointer = 1 2 3 5 4 6 7"
xset r rate 240 50

case `uname` in 
    FreeBSD|Linux|Darwin)
	export LANG=en_US.UTF-8
	;;
    CYGWIN*)
	export LANG=ja_JP.SJIS
	;;
esac

export LC_MESSAGES=en_US.UTF-8
export LC_TIME=en_US.UTF-8

XMODIFIERS=@im=skkinput
export XMODIFIERS

G_BROKEN_FILENAMES=1
export G_BROKEN_FILENAMES

#GDK_USE_XFT=0
#export GDK_USE_XFT

/bin/rm /tmp/.ICE-unix/*
/bin/rm ${HOME}/.DCOPserver*

#if [ -f ${HOME}/.xmodmap.winkey ]; then
#    xmodmap ${HOME}/.xmodmap.winkey&
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

if [ -x /usr/bin/mlterm ]; then
    if [ -x /usr/bin/screen ]; then
	mlterm --title `hostname`@mlterm \
	    --daemon=blend -e screen -UdRR &
    else
	mlterm --title mlterm@`hostname`@mlterm \
	    --daemon=blend &
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
