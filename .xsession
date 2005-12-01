# -*- shell-script -*-
# $Id$
export UNAME=`uname`
case ${UNAME} in 
    Darwin)
	export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"
	if [ -f /sw/bin/init.sh ]; then
	    source /sw/bin/init.sh
	fi
	;;
esac
export PATH="${HOME}/bin:/usr/games:${PATH}"
#xset +fp ${HOME}/lib/X11/fonts
#xset fp rehash
#xset m speed Threshold
# 加速値 == マウスの動きを指定した数値倍だけ速くする。
# 閾値 == 指定したピクセル数だけマウスポインタが移動したときに加速値が有効になる
xset m 1 20 # for Marble Mouse
xmodmap -e "pointer = 1 2 3 5 4 6 7"
xset r rate 240 50

case ${UNAME} in 
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

rm -vf /tmp/.ICE-unix/*
rm -vf ${HOME}/.DCOPserver*

case ${UNAME} in
    Darwin)
	export BINDIR=/sw/bin
	;;
    *)
	export BINDIR=/usr/bin
	;;
esac

if [ -x ${BINDIR}/X11/skkinput ]; then
    skkinput&
fi

if [ -x ${BINDIR}/esd ]; then
    esd -nobeeps&
fi

if [ -x ${BINDIR}/xscreensaver ]; then
    xscreensaver -nosplash&
fi

#if [ -x ${BINDIR}/knotes ]; then
#    knotes&
#fi

if [ -x ${BINDIR}/wmcube ]; then
    wmcube&
fi

if [ -x ${BINDIR}/wmmoonclock ]; then
    wmmoonclock&
fi

if [ -x ${BINDIR}/wmxmms ]; then
    wmxmms&
fi

if [ -x ${BINDIR}/wmpuzzle ]; then
    wmpuzzle&
fi

if [ -x ${BINDIR}/wmtimer ]; then
    wmtimer&
fi

#if [ -x ${BINDIR}/volume.app ]; then
#    volume.app&
#fi

if [ -x ${BINDIR}/mlterm ]; then
    if [ -x ${BINDIR}/screen ]; then
	mlterm --title `hostname`@mlterm \
	    --daemon=blend -e screen -UdRR &
    else
	mlterm --title mlterm@`hostname`@mlterm \
	    --daemon=blend &
    fi
fi

if [ -x ${BINDIR}/fluxbox ]; then
    fluxbox
elif [ -x ${BINDIR}/quartz-wm ]; then
    quartz-wm
fi

#if [ -x ${BINDIR}/gnome-session ]; then
#    gnome-session
#fi

#if [ -x ${BINDIR}/X11/twm ]; then
#    twm
#fi
