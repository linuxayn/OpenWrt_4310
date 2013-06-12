#!/bin/sh
insmod ipv6
echo 'start radvd'
/etc/init.d/radvd start
sleep 2
ip -6 addr del 2001:256:100:3006:222:15ff:fe69:18ed/64 dev eth0.2
ip -6 addr add 2001:256:100:3006:222:15ff:fe69:18ed/128 dev eth0.2

ip -6 addr add 2001:256:100:3006:222:15ff:fe69:182e/64 dev br-lan

ip -6 route add default via fe80::2e0:fcff:fe8f:ca36 dev eth0.2

echo 'start ndppd'
/etc/init.d/ndppd start
echo 'done'
