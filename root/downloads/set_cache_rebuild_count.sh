ip route flush cache
cat /proc/sys/net/ipv4/rt_cache_rebuild_count
echo "->"$1
echo $1 > /proc/sys/net/ipv4/rt_cache_rebuild_count
