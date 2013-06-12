n='0 1 2 3 4 5 6 7 8 9'
for i in $n; do
	echo "d zju$i"
	echo "d zju$i" >> /var/run/xl2tpd/l2tp-control
	sleep 1
done
. /root/trunk_dynamic_route.sh disable
