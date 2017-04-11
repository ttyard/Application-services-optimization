#!/bin/bash
#
# Date: 2017/04/09
# Author:Eric.Wang
#
LB_VIP=192.168.0.70
LB_RIP1=192.168.0.61
LB_RIP2=192.168.0.62

. /etc/rc.d/init.d/functions
        
logger $0 called with $1
case "$1" in
  start)
    /sbin/ipvsadm --set 30 5 60
    /sbin/ifconfig eth0:0 $LB_VIP netmask 255.255.255.255 broadcast $LB_VIP up
    /sbin/route add -host $LB_VIP dev eth0:0
    /sbin/ipvsadm -A -t $LB_VIP:80 -s wlc -p 120
    /sbin/ipvsadm -a -t $LB_VIP:80 -r $LB_RIP1:80 -g -w 1
    /sbin/ipvsadm -a -t $LB_VIP:80 -r $LB_RIP2:80 -g -w 1
    touch /var/lock/subsys/ipvsadm > /dev/null 2>&1
    echo "ipvsadm started."
    ;;

  stop)
    /sbin/ipvsadm -C
    /sbin/ipvsadm -Z
    ifconfig eth0:0 down
    route del $LB_VIP
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