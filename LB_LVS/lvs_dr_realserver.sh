#!/bin/bash
#
# Date: 2017/04/09
# Author:Eric.Wang
#
LB_VIP=192.168.0.70
. /etc/rc.d/init.d/functions

case "$1" in
    start)
        ifconfig eth1:0 $LB_VIP netmask 255.255.255.255 broadcast $LB_VIP
        /sbin/route add -host $LB_VIP dev eth1:0
        echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore        
        echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce
        
        sysctp -p > /dev/null 2>&1
        echo "RealServer Start OK."
        ;;
    stop)
        ifconfig lo:0 down
        /sbin/route del $LB_VIP > /dev/null 2>&1
        echo "0" > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo "0" > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo "0" > /proc/sys/net/ipv4/conf/all/arp_ignore        
        echo "0" > /proc/sys/net/ipv4/conf/all/arp_announce
        sysctp -p > /dev/null 2>&1
        echo "RealServer Stoped."
        ;;
    * )
        echo "Usage: $0 {start|stop}"
        exit 1
esac
exit 0