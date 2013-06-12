#!/bin/sh
if [ ${PPP_IFACE} != "l2tp0" ]; then
	exit 0
fi

logger "Notice: l2tp0 is down"

message=`netstat -t | grep ssh`
if [ -n "$message" ]; then
	logger "Find SSH connection(s), exit."
	exit 0
fi
. /root/trunk_dynamic_route.sh disable
. /root/repeat_redial.sh &
