#!/bin/sh
CONFIG_FILE='/etc/xl2tpd/xl2tpd.conf'
cat > $CONFIG_FILE << !
[global]
force userspace = yes
port = 1701
access control = yes

[lns default]
ip range = 192.168.2.202-192.168.2.210
lac = 0.0.0.0-255.255.255.255
local ip = 192.168.2.200
length bit = yes
require chap = yes
require authentication = yes
name = l2tp-server
ppp debug = no
pppoptfile = /etc/ppp/options.xl2tpd

!

n='0 1 2 3 4 5 6 7 8 9'

for i in $n; do
cat >> $CONFIG_FILE << !
[lac zju${i}]
lns = 10.5.1.9
redial = no
redial timeout = 3
max redials = 100
refuse pap = yes
require chap = yes
require authentication = yes
ppp debug = no
pppoptfile = /etc/xl2tpd/zjuvpn/zju${i}.options
!
let rand=i%3
if [ $rand  = '0' ]; then
	server='a'
elif [ $rand = '1' ]; then
	server='a'
elif [ $rand = '2' ]; then
	server='a'
fi

echo "name = username@"${server} >> $CONFIG_FILE
echo "" >> $CONFIG_FILE
done

for i in $n; do
cat > /etc/xl2tpd/zjuvpn/zju${i}.options << !
#debug
ipcp-accept-local
ipcp-accept-remote
noccp
noauth
crtscts
idle 1800
mtu 1410
lock  
#proxyarp
#defaultroute
connect-delay 5000
ifname l2tp${i} 
syncppp $1 
!
done
