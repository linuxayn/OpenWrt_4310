#!/bin/sh
t=1
message=`ifconfig | grep l2tp0`
if [ -n "$message" ]; then
	connected="y"
	logger "VPN connected!"
else                 
        connected="n"
fi
while [ "$t" -le 10 ] && [ "$connected" = "n" ]
do
	logger "Dial: $t"
	t=$(($t+1))
	. /root/all_disconnect.sh
	. /root/all_connect.sh
	message=`ifconfig | grep l2tp0`
	if [ -n "$message" ]; then
		connected="y"
		logger "VPN connected!"
	else
		connected="n"
		sleep 60
	fi
done
