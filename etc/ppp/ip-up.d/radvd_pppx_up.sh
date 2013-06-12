[ ${PPP_REMOTE:0:10} = "192.168.1." ] || {
	#logger "$PPP_IFACE not a PPTP interface"
	exit 0
}

local PREFIX="2001:256:100:3006"
local CFG_DIR="/var/etc/radvd-conf"

logger "Adding IPv6 support for $PPP_IFACE"
#Modify the following line to your IPv6 address 
ip -6 addr add ${PREFIX}:222:15ff:fe69:18${PPP_REMOTE:11:2}/64 dev $PPP_IFACE

[ -d $CFG_DIR ] || { 
	mkdir $CFG_DIR
}
local CFG_FILE="$CFG_DIR/radvd-$PPP_IFACE.conf"
echo "interface $PPP_IFACE" >$CFG_FILE
echo "{" >>$CFG_FILE
echo "AdvDefaultPreference medium;" >>$CFG_FILE
echo "IgnoreIfMissing on;" >>$CFG_FILE
echo "AdvSendAdvert on;" >>$CFG_FILE
echo "AdvSourceLLAddress on;" >>$CFG_FILE
echo "prefix $PREFIX::/64" >>$CFG_FILE
echo "{" >>$CFG_FILE
echo "AdvOnLink on;" >>$CFG_FILE
echo "AdvAutonomous on;" >>$CFG_FILE
#echo "UnicastOnly on;" >>$CFG_FILE
echo "};" >>$CFG_FILE
echo "};" >>$CFG_FILE
/etc/init.d/radvd restart
