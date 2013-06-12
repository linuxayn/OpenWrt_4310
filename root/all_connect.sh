#!/bin/sh
#n='0 1 2 3 4 5 6 7'
n='0 1 2 3'
export n
for i in $n; do
	logger "c zju$i"
	logger "c zju$((i+1))"
	logger "c zju$((i+1))"
	echo "c zju"$i >> /var/run/xl2tpd/l2tp-control
done
sleep 5
. /root/trunk_dynamic_route.sh enable

