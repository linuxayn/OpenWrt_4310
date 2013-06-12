#!/bin/sh

# copy route to every table
if [ ${PPP_IFACE:0:3} = "ppp" ]; then
	. /root/trunk_dynamic_route.sh enable
fi
