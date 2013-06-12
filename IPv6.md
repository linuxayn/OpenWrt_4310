Date: 2013-03-16 13:15:05
Title: OpenWrt IPv6配置指南  
```
Author: @linuxayn 
2013-03-19 测试版
声明：尽最大努力避免错误纰漏，但仅供参考。
```
##假设读者
1. 会用SSH连接管理OpenWrt  
2. 会基本的OpenWrt操作  
3. 所在位置有IPv6双栈接入（能自动获取到IPv6地址，如30、31、32舍）  

##安装kmod-ipv6  
配置好源之后，在路由器终端下输入：  

    root@OpenWrt:~#opkg update
    root@OpenWrt:~#opkg install kmod-ipv6
如果提示说你当前系统内核不匹配的话，先将系统升级成当前源的内核再尝试安装。  

##配置  
在网络设置里启用IPv6：  
```
#filename: /etc/config/network
config interface 'wan'
	option ifname 'eth0.2'
	option proto 'static'
	option ipaddr '-.-.-.-'
	option netmask '255.255.255.0'
	option macaddr '-:-:-:-:-:-'
	option dns '10.10.0.21'
	**option ipv6 '1'** #启用IPv6
	option mtu '1452'
```
重启一下网络看看是否能获取到IPv6地址：  

    root@OpenWrt:~#/etc/init.d/network restart
    root@OpenWrt:~#ifconfig

到达这里可能会有IPv6地址，看起来应该是这样的（有inet6地址）：  
```
eth0.2    Link encap:Ethernet  HWaddr -:-:-:-:-:-
          inet addr:-.-.-.-  Bcast:-.-.-.-  Mask:255.255.255.0
          inet6 addr: **2001:256:100:3006:-:-:-:-/64** Scope:Global
          inet6 addr: **fe80::-:-:-:-/64** Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1452  Metric:1
```
如果能看到IPv6的地址，可以试试ping一下bt.neu6.edu.cn看看是否能通。不过更可能是没有IPv6地址。先不要急着重启路由器，这里还存在一个问题，按上述配置之后重启路由器后IPv6就不能用了。这主要是因为IPv6在路由器里的启动顺序太早从而获取不到IPv6地址，可以按下面这个方法：

先修改/etc/modules.d/20-ipv6
```
#filename: /etc/modules.d/20-ipv6
#ipv6 #注释掉这一行
```
然后在/etc/rc.local里加上：  
```
#filename: /etc/rc.local
insmod ipv6
```  
这样的话路由器重新启动应该就可以自动获取到IPv6地址了。有一个问题是，现在重启网络（但不重启路由器），IPv6就不能用了，只能通过重启路由器来重新获取地址，这个问题暂时无解。另外一个问题是现在只能在路由器里访问IPv6的内容，接路由器的电脑是不能访问IPv6的。下面要配置客户端的IPv6，比较复杂，因为是根据记忆所写，步骤可能会有疏漏，不一定会work，仅供参考吧。

##配置客户端的IPv6  
安装两个包：  

    root@OpenWrt:~#opkg install radvd
    root@OpenWrt:~#opkg install ndppd

其中radvd用于IPv6地址自动配置，也就是给客户端分配IPv6地址；ndppd用于代理NDP (Neighbor Discovery Protocol)信息。工作原理可以参考这篇文章：http://rockuw.sinaapp.com/openwrt-buffalo-g300n-v2-router-hack/。  

假设学校分配给我的地址是2001:256:100:3006:AAAA:BBBB:CCCC:DDDD/64（大家分配到的应该都是64的前缀长度）。先配置radvd，使得客户端能获得IPv6地址：  
```
#filename: /etc/config/radvd
config interface
	option interface	'lan'
	option AdvSendAdvert	1
	option AdvManagedFlag	0
	option AdvOtherConfigFlag 0
	list client		''
	#option ignore		1
config prefix
	option interface	'lan'
	# If not specified, a non-link-local prefix of the interface is used
	list prefix		'2001:256:100:3006::/64' #这里写你的IPv6头几位地址，如果是30,31,32舍的话就和这里写的一样
	option AdvOnLink	1
	option AdvAutonomous	1
	option AdvRouterAddr	0
	#option ignore		1
config route
	option interface	'lan'
	list prefix		''
	option ignore		1
config rdnss
	option interface	'lan'
	# If not specified, the link-local address of the interface is used
	list addr		''
	option ignore		1
config dnssl
	option interface	'lan'
	list suffix		''
	option ignore		1
```  
然后配置ndppd：  
```
#filename: /etc/ndppd.conf
route-ttl 30000
proxy eth0.2 {  #这里改为你的wan口的地址      
   router yes
   timeout 500
   ttl 30000
   rule 2001:256:100:3006::/64 { #这里写你的IPv6头几位地址，如果是30,31,32舍的话就和这里写的一样
      auto
   }
}
```

整套IPv6启动脚本是像下面这样的（可以将其放在/etc/rc.local里面自启动）：  
```
#filename: /root/ipv6.sh
insmod ipv6 #先启动IPv6
echo 'start radvd'
/etc/init.d/radvd start #再启动radvd
sleep 2
ip -6 addr del 2001:256:100:3006:AAAA:BBBB:CCCC:DDDD/64 dev eth0.2 #强制将本来是64的前缀长度改为128的前缀长度
ip -6 addr add 2001:256:100:3006:AAAA:BBBB:CCCC:DDDD/128 dev eth0.2
ip -6 addr add 2001:256:100:3006:AAAA:BBBB:CCCC:EEEE/64 dev br-lan #给内网接口强制指定一个64前缀长度的另外一个IPv6地址，随便改动一下自己原来IP后两位就好了，一般不会和别人碰撞的。
ip -6 route add default via fe80::-:-:-:- dev eth0.2 #强制加上默认路由，网关就写你的网关就好了，可以在获取到学校分配的IPv6地址后用ip -6 route来查看，是以fe80::开头的地址。
echo 'start ndppd'
/etc/init.d/ndppd start #最后启动ndppd
echo 'done'
```
启动之后，应该可以在客户端也使用IPv6了...