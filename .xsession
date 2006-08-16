# -*- shell-script -*-
# $Id$

UNAME=$(uname); export UNAME

case ${UNAME} in 
    Darwin)
	PATH="/usr/local/bin:/usr/local/sbin:${PATH}"; export PATH
	if [ -f /sw/bin/init.sh ]; then
	    source /sw/bin/init.sh
	fi
	;;
esac
PATH="${HOME}/bin:/usr/games:${PATH}"; export PATH

#xset m speed Threshold
# 加速値 == マウスの動きを指定した数値倍だけ速くする
# 閾値 == 指定したピクセル数だけマウスポインタが移動したときに加速値が有効になる
xset m 1 20 # for Marble Mouse
xset r rate 240 50
# Marble Mouse を使うなら以下を有効にする.
# xmodmap -e "pointer = 1 2 3 5 4 6 7"

case ${UNAME} in 
    FreeBSD|Linux|Darwin)
	LANG=en_US.UTF-8; export LANG
	LC_CTYPE=ja_JP.UTF-8; export LC_CTYPE
	;;
    CYGWIN*)
	LANG=ja_JP.SJIS; export LANG
	LC_TIME=en_US.UTF-8; export LC_TIME
	LC_MESSAGES=en_US.UTF-8; export LC_MESSAGES
	;;
esac

GTK_IM_MODULE=uim ; export GTK_IM_MODULE
QT_IM_MODULE=uim ; export QT_IM_MODULE
XMODIFIERS=@im=uim ; export XMODIFIERS

if type uim-xim &> /dev/null ; then
  uim-xim &
fi

if type esd &> /dev/null; then
    esd -nobeeps&
fi

if type xscreensaver &> /dev/null; then
    xscreensaver -nosplash&
fi

for CMD in wmcube wmmoonclock wmxmms wmpuzzle wmtimer volume.app; do
    if type ${CMD} &> /dev/null;then
	${CMD} &
    fi
done

if type mlterm &> /dev/null; then
    if type screen &> /dev/null; then
	mlterm --title `hostname`@mlterm \
	    --daemon=blend -e screen -UxRR &
    else
	mlterm --title mlterm@`hostname`@mlterm \
	    --daemon=blend &
    fi
elif type xterm &> /dev/null; then
	xterm &
fi

if type fluxbox &> /dev/null; then
    fluxbox
elif type quartz-wm &> /dev/null; then
    quartz-wm
elif type twm &> /dev/null; then
    twm
fi
