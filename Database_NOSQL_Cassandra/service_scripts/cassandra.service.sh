#!/bin/bash
### BEGIN INIT INFO
# Provides:          cassandra
# Required-Start:    $remote_fs $network $named $time
# Required-Stop:     $remote_fs $network $named $time
# Should-Start:      ntp mdadm
# Should-Stop:       ntp mdadm
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: distributed storage system for structured data
# Description:       Cassandra is a distributed (peer-to-peer) system for
#                    the management and storage of structured data.
### END INIT INFO
#
# Author: Lijie.Wang
#

DESC="Cassandra"
NAME=cassandra
CONFDIR=/opt/apache-cassandra-3.10/conf
CASSANDRA_HOME=/opt/apache-cassandra-3.10
CASSANDRA_CONF=$CONFDIR
PIDFILE=$CASSANDRA_HOME/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
CASSANDRA_JAR=lib/apache-cassandra-3.10.jar
#Location of JAVA_HOME (bin files)
export JAVA_HOME=/opt/jdk1.8.0_101

#Add Java binary files to PATH
export PATH=$JAVA_HOME/bin:$PATH

#CASSANDRA_USER is the default user of cassandra
export CASSANDRA_USER=cassandra

#CASSANDRA_USAGE is the message if this script is called without any options
CASSANDRA_USAGE="Usage: $0 {\e[00;32mstart\e[00m|\e[00;31mstop\e[00m|\e[00;31mkill\e[00m|\e[00;32mstatus\e[00m|\e[00;31mrestart\e[00m}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=2

cassandra_pid() {   
    echo `ps -ef | grep $CASSANDRA_HOME | grep -v grep |grep $CASSANDRA_JAR| tr -s " "|cut -d" " -f2`
}

start() {
    DIR_OWNER=`ls -ld $CASSANDRA_HOME |awk '{print $3}'`
    if ! [ $CASSANDRA_USER == $DIR_OWNER ]
    then
        echo -e "\e[00;31m Please make sure that the $CASSANDRA_USER user has read and write $CASSANDRA_HOME permissions\e[00m"
      exit 0
    fi
    
    pid=$(cassandra_pid)
    if [ -n "$pid" ]
    then
        echo -e "\e[00;31mCassandra is already running (pid: $pid)\e[00m"
    else
        # Start cassandra
            echo -e "\e[00;32mStarting cassandra\e[00m"
        if [ `user_exists $CASSANDRA_USER` = "1" ]
        then
            /bin/su $CASSANDRA_USER -c $CASSANDRA_HOME/bin/cassandra -p $PIDFILE > /dev/null 2>&1
        else
            echo -e "\e[00;31mCassandra user $CASSANDRA_USER does not exists."
            #echo -e "\e[00;31mCassandra user $CASSANDRA_USER does not exists. Starting with $(id)\e[00m"
            #sh $CASSANDRA_HOME/bin/cassandra -p $PIDFILE -> /dev/null 2>&1
        fi
        status
    fi
    return 0
}

status(){
    pid=$(cassandra_pid)
    if [ -n "$pid" ]
        then echo -e "\e[00;32mCassandra is running with pid: $pid\e[00m"
    else
        echo -e "\e[00;31mCassandra is not running\e[00m"
        return 3
    fi
}

terminate() {
	echo -e "\e[00;31mTerminating Cassandra\e[00m"
	kill -9 $(cassandra_pid)
    if [ -f $PIDFILE ]
    then
        /bin/su $CASSANDRA_USER -c rm $PIDFILE
    fi
}

stop() {
    pid=$(cassandra_pid)
    if [ -n "$pid" ]
    then
        echo -e "\e[00;31mStoping Cassandra\e[00m"
    #/bin/su -p -s /bin/sh $CASSANDRA_USER
    #sh $CASSANDRA_HOME/bin/shutdown.sh
    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
        echo -n -e "\n\e[00;31mwaiting for processes to exit\e[00m";
        sleep 1
        let count=$count+1;
    done

    if [ $count -gt $kwait ]; then
        echo -n -e "\n\e[00;31mkilling processes didn't stop after $SHUTDOWN_WAIT seconds\e[00m \n"
        terminate
    fi
    else
        echo -e "\n \e[00;31mCassandra is not running\e[00m"
    fi

    return 0
}

user_exists(){
    if id -u $1 >/dev/null 2>&1; then
        echo "1"
    else
        echo "0"
    fi
}

case $1 in
	start)
        start
	;;
	stop)
        stop
	;;
	restart)
        stop
        start
	;;
	status)
		status
		exit $?
	;;
	kill)
		terminate
	;;
	*)
		echo -e $CASSANDRA_USAGE
	;;
esac
exit 0