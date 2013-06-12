适用网络环境：浙江大学VPN拨号上网
OpenWrt版本：attitude adjustment 12.09

注意事项
--------------------------
1. 这个项目并非给beginner使用的，仅仅为了减少配置时候走的弯路。
1. 请确信你读懂了脚本后再修改成为你的网络配置！
2. 注意这仅仅是一下配置文件以及脚本，需要自己安装对应的程序!

特性
-----------------------
- IPv6双栈支持
- VPN拨号（支持多拨）
- PPTP VPN服务器（支持IPv6）
- 自动重拨（*有bug*）

内网讨论
----------------------
http://www.cc98.org/dispbbs.asp?boardID=328&ID=4127033&page=

已安装的软件包
----------------------
```shell
root@OpenWrt:~# opkg list-installed
base-files - 117-r36088
busybox - 1.19.4-6
dnsmasq - 2.62-2
dropbear - 2011.54-2
firewall - 2-55.1（已被禁用）
hotplug2 - 1.0-beta-4
ip - 3.3.0-1
iptables - 1.4.10-4
iptables-mod-conntrack-extra - 1.4.10-4（用于多拨）
iptables-mod-ipopt - 1.4.10-4（用于多拨）
iw - 3.6-1
jshn - 2013-01-29-0bc317aa4d9af44806c28ca286d79a8b5a92b2b8
kernel - 3.3.8-1-d6597ebf6203328d3519ea3c3371a493
kmod-ath - 3.3.8+2012-09-07-3
kmod-ath9k - 3.3.8+2012-09-07-3
kmod-ath9k-common - 3.3.8+2012-09-07-3
kmod-cfg80211 - 3.3.8+2012-09-07-3
kmod-crypto-aes - 3.3.8-1
kmod-crypto-arc4 - 3.3.8-1
kmod-crypto-core - 3.3.8-1
kmod-fs-ext4 - 3.3.8-1
kmod-fuse - 3.3.8-1
kmod-gpio-button-hotplug - 3.3.8-1
kmod-gre - 3.3.8-1
kmod-ipt-conntrack - 3.3.8-1
kmod-ipt-conntrack-extra - 3.3.8-1
kmod-ipt-core - 3.3.8-1
kmod-ipt-ipopt - 3.3.8-1
kmod-ipt-nat - 3.3.8-1
kmod-ipt-nathelper - 3.3.8-1
kmod-ipv6 - 3.3.8-1（IPv6支持）
kmod-leds-gpio - 3.3.8-1
kmod-ledtrig-default-on - 3.3.8-1
kmod-ledtrig-netdev - 3.3.8-1
kmod-ledtrig-timer - 3.3.8-1
kmod-ledtrig-usbdev - 3.3.8-1
kmod-lib-crc-ccitt - 3.3.8-1
kmod-lib-crc16 - 3.3.8-1
kmod-mac80211 - 3.3.8+2012-09-07-3
kmod-nls-base - 3.3.8-1
kmod-ppp - 3.3.8-1
kmod-pppoe - 3.3.8-1
kmod-pppox - 3.3.8-1
kmod-scsi-core - 3.3.8-1
kmod-usb-core - 3.3.8-1
kmod-usb-ohci - 3.3.8-1
kmod-usb-storage - 3.3.8-1
kmod-usb2 - 3.3.8-1
kmod-wdt-ath79 - 3.3.8-1
libblobmsg-json - 2013-01-29-0bc317aa4d9af44806c28ca286d79a8b5a92b2b8
libc - 0.9.33.2-1
libcurl - 7.29.0-1
libdaemon - 0.14-2
libevent2 - 2.0.19-1
libgcc - 4.6-linaro-1
libip4tc - 1.4.10-4
libiwinfo - 36
libiwinfo-lua - 36
libjson - 0.9-2
liblua - 5.1.4-8
libminiupnpc - 1.8-1
libnl-tiny - 0.1-3
libopenssl - 1.0.1e-1
libpthread - 0.9.33.2-1
librt - 0.9.33.2-1
libubox - 2013-01-29-0bc317aa4d9af44806c28ca286d79a8b5a92b2b8
libubus - 2013-01-13-bf566871bd6a633e4504c60c6fc55b2a97305a50
libubus-lua - 2013-01-13-bf566871bd6a633e4504c60c6fc55b2a97305a50
libuci - 2013-01-04.1-1
libuci-lua - 2013-01-04.1-1
libxml2 - 2.7.8-2
libxtables - 1.4.10-4
lua - 5.1.4-8
luci - 0.11.1-1
luci-app-firewall - 0.11.1-1
luci-i18n-english - 0.11.1-1
luci-lib-core - 0.11.1-1
luci-lib-ipkg - 0.11.1-1
luci-lib-nixio - 0.11.1-1
luci-lib-sys - 0.11.1-1
luci-lib-web - 0.11.1-1
luci-mod-admin-core - 0.11.1-1
luci-mod-admin-full - 0.11.1-1
luci-proto-core - 0.11.1-1
luci-proto-ppp - 0.11.1-1
luci-sgi-cgi - 0.11.1-1
luci-theme-base - 0.11.1-1
luci-theme-openwrt - 0.11.1-1
mtd - 18.1
ndppd - 0.2.2-2
netifd - 2013-01-29.2-4bb99d4eb462776336928392010b372236ac3c93
ntfs-3g - 2011.4.12-1-fuseint
openssh-sftp-server - 6.1p1-1
opkg - 618-3
ppp - 2.4.5-4（这个ppp是打过patch的，参考http://www.morfast.net/blog/linux/pppoe-multilink/ 以及 https://openwrt.org.cn/browser/backfire/package/ppp/patches/360-syncppp.patch?rev=361）
ppp-mod-pppoe - 2.4.5-8
pptpd - 1.3.4-2（PPTP VPN服务器）
radvd - 1.9.1-2（IPv6支持）
swconfig - 10
transmission-daemon - 2.71-1 （BT下载）
uboot-envtools - 2012.04.01-1
ubus - 2013-01-13-bf566871bd6a633e4504c60c6fc55b2a97305a50
ubusd - 2013-01-13-bf566871bd6a633e4504c60c6fc55b2a97305a50
uci - 2013-01-04.1-1
uclibcxx - 0.2.4-1
uhttpd - 2012-10-30-e57bf6d8bfa465a50eea2c30269acdfe751a46fd
vsftpd - 3.0.2-1 （FTP下载）
wpad-mini - 20120910-1
xl2tpd - 1.2.5-1 （学校VPN拨号）
zlib - 1.2.7-1
```