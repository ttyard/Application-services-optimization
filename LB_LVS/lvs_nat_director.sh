#!/bin/bash
#
# Date: 2017/04/09
# Author:Eric.Wang
#
LB_DR=192.168.0.70
LB_RIP1=10.1.1.11
LB_RIP2=10.1.1.12

. /etc/rc.d/init.d/functions
        
logger $0 called with $1
case "$1" in
  start)
    #启用Director路由转发
    echo 1 > /proc/sys/net/ipv4/ip_forward
    #关闭ICMP的重定向
    echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
    echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
    echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
    echo 0 > /proc/sys/net/ipv4/conf/eth1/send_redirects
    #iptables规则设置,清空规则表,创建私网SNAT
    iptables -t nat -F
    iptables -t nat -X
    iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -j MASQUERADE
    
    /sbin/ipvsadm -C
    /sbin/ipvsadm -A -t $LB_DR:80 -s wlc -p 120
    /sbin/ipvsadm -a -t $LB_DR:80 -r $LB_RIP1:80 -m -w 1
    /sbin/ipvsadm -a -t $LB_DR:80 -r $LB_RIP2:80 -m -w 1
    touch /var/lock/subsys/ipvsadm > /dev/null 2>&1
    echo "ipvsadm started."
    ;;

  stop)
    #清除LVS配置
    /sbin/ipvsadm -C
    /sbin/ipvsadm -Z
    #禁用Director路由转发
    echo 1 > /proc/sys/net/ipv4/conf/all/ip_forward
    #启用ICMP的重定向
    echo 1 > /proc/sys/net/ipv4/conf/all/send_redirects
    echo 1 > /proc/sys/net/ipv4/conf/default/send_redirects
    echo 1 > /proc/sys/net/ipv4/conf/eth0/send_redirects
    echo 1 > /proc/sys/net/ipv4/conf/eth1/send_redirects
    rm -rf /var/lock/subsys/ipvsadm > /dev/null 2>&1 
    echo "ipvsadm stopd"
    ;;
  status)
    if [ ! -e /var/lock/subsys/ipvsadm ];then
      echo "ipvsadm stoped"
      exit 1
    else
      echo "ipvsadm OK"
    fi
    ;;

  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1

esac