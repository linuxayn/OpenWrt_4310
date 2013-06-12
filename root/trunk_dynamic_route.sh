#!/bin/sh

n='0 1 2 3'

enable () {
	echo "enabling dynamic route"
	j=10
	
	ip rule flush
	ip rule add lookup main prio 32766
	ip rule add lookup default prio 32767
	
	iptables -t mangle -F PREROUTING
	iptables -t mangle -F POSTROUTING
	
	cmd="ip route replace default scope global "

	for i in $n; do
		let j=j+1
		
		ifname=l2tp${i}
		ipaddr=`ifconfig $ifname|grep 'inet addr'|cut -d ':' -f2|cut -d ' ' -f1`
		gateway=`ifconfig $ifname|grep 'P-t-P'|cut -d ':' -f3|cut -d ' ' -f1`
		
		ip rule add from $ipaddr table $j prio $j
		ip rule add fwmark 0x0$j table $j prio $j
		ip route flush table $j
		
		ip route | grep link | while read ROUTE
		do
			ip route append $ROUTE table $j
		done
		ip route add default via $gateway dev $ifname table $j
		
		iptables -t mangle -A PREROUTING -i $ifname -m conntrack --ctstate NEW -j CONNMARK --set-mark 0x0$j
		iptables -t mangle -A POSTROUTING -o $ifname -m conntrack --ctstate NEW -j CONNMARK --set-mark 0x0$j
		
		cmd="$cmd nexthop dev $ifname weight 1"
		
	done
	
	iptables -t mangle -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j CONNMARK --restore-mark
	eval $cmd	
			
	ip route flush cache
}

disable () {
	echo "disabling dynamic route"
	ip rule flush
	ip rule add lookup main prio 32766
	ip rule add lookup default prio 32767
	
	iptables -t mangle -F PREROUTING
	iptables -t mangle -F POSTROUTING
	
	ip route flush cache
}

action=$@
if [ $action = "enable" ]; then
	enable
elif [ $action = "disable" ]; then
	disable
fi
