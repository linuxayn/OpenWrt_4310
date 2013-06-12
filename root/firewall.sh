# This file is interpreted as shell script.
# Put your custom iptables rules here, they will
# be executed with each firewall (re-)start.

iptables -F

iptables -t filter -F
iptables -t filter -o l2tp+ -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -m tcp -j TCPMSS --clamp-mss-to-pmtu
iptables -t filter -o ppp+ -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -m tcp -j TCPMSS --clamp-mss-to-pmtu

iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0.2 -j MASQUERADE
iptables -t nat -A POSTROUTING -o l2tp+ -j MASQUERADE

#iptables -A output_rule -p 47 -j ACCEPT
#iptables -A input_rule -p 47 -j ACCEPT
#iptables -A input_rule -p tcp --dport 1723 -j ACCEPT
#iptables -A input_rule -p tcp --dport 51413 -j ACCEPT

#iptables -A input_rule -i l2tp+ -j ACCEPT
#iptables -A output_rule -o l2tp+ -j ACCEPT
#iptables -A forwarding_rule -i l2tp+ -j ACCEPT
#iptables -A forwarding_rule -o l2tp+ -j ACCEPT
