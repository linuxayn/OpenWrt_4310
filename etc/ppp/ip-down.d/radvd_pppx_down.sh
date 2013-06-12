[ ${PPP_REMOTE:0:10} = '192.168.1.' ] || {
	exit 0
}
local CFG_DIR="/var/etc/radvd-conf"
[ -f ${CFG_DIR}/radvd-${PPP_IFACE}.conf ] && {
	rm ${CFG_DIR}/radvd-${PPP_IFACE}.conf
	/etc/init.d/radvd restart
}
