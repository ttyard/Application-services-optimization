#!/bin/bash
#
# Author: Eric.Wang
# Date: 2017/04/12
#

nginx_processes_counts=$(ps -C nginx --no-headers|wc -l)

if [ $nginx_processes_counts eq 0 ];then
    #CENTOS6,Ubuntu14.04
    /etc/init.d/nginx start
    sleep 2
    nginx_processes_counts=$(ps -C nginx --no-heading)
    if [ $nginx_processes_counts eq 0 ];then
        /etc/init.d/keepalived stop
    fi
fi