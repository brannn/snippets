#!/bin/sh
# Author       : Brandon Huey <brandon.huey@me.com>
# Description  : Util to clean shared IPC resources on busy web servers
# $Id$


if [ "$(id -un)" != "user" ] 
then
        echo "This script must be run as user" 1>&2
        exit 1
fi

stop_apache() {
        echo "*** stopping httpd"
        /opt/apache2/bin/apachectl stop
        echo "*** waiting 5 seconds"
        sleep 5
}

start_apache() {
        /opt/apache2/bin/apachectl start
        sleep 2
        PROCESS="/var/httpd/logs/httpd.pid"
                if [ ! -f "$PROCESS" ]
                then
                        echo "*** could not restart httpd"
                else
                        echo "*** httpd restarted"
       fi
}

clear_ipc() {
        for shm in `ipcs -m | grep user | cut -c12-22`
        do
                ipcrm -m $shm
                echo "*** cleared shm IPC"
        done
       
        for sem in `ipcs -s | grep user | cut -c12-22`
        do
                ipcrm -s $sem
                echo "*** cleared sem IPC"
        done
}

RUNNING="/var/httpd/logs/httpd.pid"

if [ ! -f "$RUNNING" ]
then 
        clear_ipc
        start_apache
else
        stop_apache
        clear_ipc
        start_apache
fi

