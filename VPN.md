Date: 2013-03-15 18:24:41
Title: OpenWrt VPN配置指南  
```
Author: @linuxayn 
2013-03-15 初稿
2013-03-19 增加dns部分
声明：尽最大努力避免错误纰漏，但仅供参考。
```
##假设读者
1. 会用SSH连接管理OpenWrt  
2. 会基本的OpenWrt操作   

##连接内网  
在拨VPN之前首先必须保证能连接内网，即能和VPN服务器通信。如果无法ping通10.5.1.9的话，请先配置内网IP、网关、静态路由。  

配置内网IP： /etc/config/network  
```
#filename: /etc/config/network
config interface 'wan' 
        option ifname 'eth0.2'  #这里写连接学校网络的接口
        option proto 'static'     #静态方式
        option ipaddr '**ipaddress**(-.-.-.-)'    #这里写你分配到的内网IP
        option netmask '255.255.255.0'    #掩码，默认即可
        option macaddr '**macaddress**(-:-:-:-:-:-)' #这里写你分配到的MAC地址
        option dns '10.10.0.21'       #DNS地址
        option mtu '1452'    #MTU
```
配置静态路由，还是刚才的文件：
```
#filename: /etc/config/network
config route
        option interface 'wan'
        option target '10.0.0.0' 
        option netmask '255.0.0.0'
        option gateway '**gateway**(-.-.-.-)' #网关地址
        option metric '1'
config route
        option interface 'wan'
        option target '210.32.0.0'
        option netmask '255.255.240.0'
        option gateway '**gateway**(-.-.-.-)' #网关地址
        option metric '1'
config route 
        option interface 'wan'
        option target '210.32.128.0'
        option netmask '255.255.192.0
        option gateway '**gateway**(-.-.-.-)' #网关地址
        option metric '1'
config route
        option interface 'wan'
        option target '222.205.0.0'
        option netmask '255.255.128.0'
        option gateway '**gateway**(-.-.-.-)' #网关地址
        option metric '1'
```
配置完成后重启一下网络(记得无论如何修改/etc/config/network文件都要保证自己可以访问，所以关于lan部分要谨慎修改)：  
    
    /etc/init.d/network restart

看看是否能```ping```通[www.cc98.org](www.cc98.org)。如果能ping通的话则说明包括dns在内的内网网络已经配置好了。

##安装软件包xl2tpd  
在连接VPN之前，路由器是无法访问外网的，所以不能从官方源处安装xl2tpd包。因此必须自己在官方手动下载xl2tpd后用opkg安装。OpenWrt的安装包格式为.ipk，如果有官方编译好的ipk的话可以在[http://downloads.openwrt.org/](http://downloads.openwrt.org/)根据你的OpenWrt版本和硬件平台下载。注意某些路由器（例如华为HG255D）的硬件芯片比较特殊，官方没有直接支持，你可以自己手动编译或者使用网友提供编译好的。

以我的路由器为例，下载地址如下：http://downloads.openwrt.org/attitude_adjustment/12.09-beta/ar71xx/generic/packages/xl2tpd_1.3.1-1_ar71xx.ipk，其中attitude_adjustment/12.09-beta是OpenWrt版本号，ar71xx是硬件平台。

我用的版本号xl2tpd - 1.2.5-1，这不是最新版的因为最新版的1.3.1似乎不能拨两个以上的VPN。如果你不在乎拨多个VPN的话，这点应该没有什么关系。  

用WinSCP将下载的ipk上传到路由器里，用opkg安装即可：  
    
    root@OpenWrt:~#opkg install xl2tpd_1.3.1-1_ar71xx.ipk

##配置xl2tpd
涉及到的几个配置文件分别是：

配置VPN的用户名密码：/etc/ppp/chap-secret
```
#filename: /etc/ppp/chap-secret
#USERNAME  PROVIDER  PASSWORD  IPADDRESS
**vpnuser**            \*      **vpnpassword**      \*
```
其中，vpnuser指VPN用户名，根据VPN的类型记得加上@a(或者@c,@d)，vpnpassword指VPN密码。用空格隔开，星号表示任意provider或者任意ipaddress，不可以省略。

  
配置L2TP拨号选项：/etc/xl2tpd/xl2tpd.conf   
```  
#filename: /etc/xl2tpd/xl2tpd.conf  
[global]
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
#新建以下内容
[lac zju]
name = **vpnuser**  #VPN用户名，不用写密码
lns = 10.5.1.9  #尽量用这个服务器，10.5.1.7这个服务器似乎有点问题
redial = no  #是否自动重拨
redial timeout = 3  #自动重拨时间间隔
max redials = 0   #自动重拨最大次数
refuse pap = yes  #验证方式，按VPN服务器要求
require chap = yes  #验证方式
require authentication = yes  #验证方式
ppp debug = no  #是否debug
pppoptfile = /etc/xl2tpd/zju.options
```
新建配置PPP拨号选项：/etc/xl2tpd/zju.options
```  
#filename:  /etc/xl2tpd/zju.options  
#debug
ipcp-accept-local
ipcp-accept-remote
noccp
noauth
crtscts
idle 1800
mtu **1410** #设置MTU，服务器要求。默认的是1500，会频繁掉线
lock
#proxyarp
defaultroute  #默认路由
connect-delay 5000
ifname l2tp  #设置接口名称
```

##连接与断开
首先将xl2tpd服务启动起来：
  
    root@OpenWrt:~#/etc/init.d/xl2tpd start  

如果需要开机自动启动的话：

    root@OpenWrt:~#/etc/init.d/xl2tpd enable

连接时，在终端任意位置输入并回车：

    root@OpenWrt:~#echo "c zju" >> /var/run/xl2tpd/l2tp-control
如果需要开机自动连接VPN的话，在/etc/rc.local里多加一行，写上这条命令即可（不过必须设置xl2tpd是开机自动启动的）。
稍等几秒后，用```ifconfig```命令看看是否一个新的叫做l2tp的接口被启动。看起来应该是类似这样的：
```  
l2tp     Link encap:Point-to-Point Protocol
          inet addr:222.205.-.-  P-t-P:10.5.1.5  Mask:255.255.255.255
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1410  Metric:1
          RX packets:15420181 errors:23 dropped:0 overruns:0 frame:0
          TX packets:28639844 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:4042656871 (3.7 GiB)  TX bytes:3264582739 (3.0 GiB)
```
在路由器终端里尝试```ping 8.8.8.8```看看是否能ping通。

断开时，在终端任意位置输入并回车：

    root@OpenWrt:~#echo "d zju" >> /var/run/xl2tpd/l2tp-control

##设置客户端DNS  
现在在路由器端应该可以连通外网了，可是在客户端只能通过IP地址来访问网络，具体表现是QQ能上，但是网页无法打开。一个解决方法是手动在客户端设置dns，将本地链接（有线连入）或者WIFI适配器（无线连入）的DNS设置为学校的dns：10.10.0.21或者10.10.2.53。缺陷是每个客户端都要重复设置一遍。  

另外一个方法是配置路由器的dnsmasq，使得路由器能转发客户端的dns请求到上级dns服务器。确保路由器已安装有dnsmasq，这个默认都会安装的。且默认dhcp服务器分配给客户端的dns是路由器的IP，如192.168.1.1。  然后修改如下文件：  
```
#filename: /etc/resolv.conf
search lan
nameserver 127.0.0.1
```  
设置上级dns服务器，前两个是学校的dns，最后一个是google的dns（可选）。
```
#filename: /etc/resolv.dnsmasq
nameserver 10.10.0.21
nameserver 10.10.2.53
nameserver 8.8.8.8
```  
如此设置后可能会无法解析内网域名，如CC98和NHD，需要在/etc/config/dhcp文件里，将rebind_protection改成0
```
#filename: /etc/config/dhcp
config dnsmasq
    option rebind_protection 0  # disable if upstream must serve RFC1918 addresses
```  
最后记得重启一下dnsmasq，使得上述改动生效。  

    root@OpenWrt:~#/etc/init.d/dnsmasq restart


