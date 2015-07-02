#!/bin/sh

###
# This start script starts up the RTB UserUpdater daemon.
# 
# For log sym linking it is important ot know that log4j is hard coded to log to:
# log4j.appender.FILE.File=${catalina.base}/logs/rtbuserupdater.log
# log4j.appender.ALERT.File=${catalina.base}/logs/rtbuserupdater/userupdater-alert.log
## check config ##
# chkconfig: 2345 85 15
# description: userupdater server
###

export APPUSER="rtuserfeed"
export APPNAME="rtbuserupdater"
export APP_UID=`id -u $APPUSER`
export APPHOME='/var/rsi/rtb/userupdater/latest'
# this script
export CURRENT_SCRIPT="/etc/init.d/userupdater"
# 'latest' log sym links
export APP_LOG_BASE="/var/rsi/logs/userupdater"
export APP_OUT="${APP_LOG_BASE}/${APPUSER}-stdout.log"
export APP_OUT_SYM="${APP_LOG_BASE}/${APPUSER}_stdout_latest.log"
export APP_ALERT="${APP_LOG_BASE}/${APPUSER}-alert.log"
export APP_ALERT_SYM="${APP_LOG_BASE}/${APPUSER}_alert_latest.log"
#java options
export FREQ_JVM_OPTS=" -Xms6144m -Xmx6144m -Dlog.dir=${APP_LOG_BASE} -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9012 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "

# Specific to this app
export PIDFILE="/var/rsi/run/${APPUSER}/${APPNAME}.pid"
export APP_CLASSPATH=$( echo ${APPHOME}/classes ${APPHOME}/lib/*.jar | sed 's/ /:/g')

start()
{

        if [ -f $PIDFILE ]; then
            if ps ax |grep -v grep |grep `cat $PIDFILE` > /dev/null 2>&1; then
                    echo " -- $APPNAME is already running "
                    exit 1
            fi
        fi
        # Starts application if invoking user is freqcap #
        if [ "$UID" == "$APP_UID" ]; then
                echo "Starting $APPNAME ..."
                echo $APP_CLASSPATH
                export COMMAND="java $FREQ_JVM_OPTS -cp $APP_CLASSPATH com.audiencescience.apollo.userdata.realtime.RealtimeUserStoreUpdater"
                cd ${APP_LOG_BASE} && ( $COMMAND 2>&1 & )
                sleep 5
                echo " -- It may take some time for it to start"
                ps auxww | grep java | grep userupdater | awk '{print $2}' >${PIDFILE}
        fi

        # if we run as root su to APPUSER
        if [ "$UID" == "0" ]; then
                su - $APPUSER -c "$CURRENT_SCRIPT start"
        fi
}

stop()
{

    if [ -f $PIDFILE ]; then
        if [ "$UID" == "$APP_UID" ]; then
                echo -n "Stopping $APPNAME ..."
                kill `cat ${PIDFILE}`
                echo " -- It may take some time for it to stop"
                for ((j=0;j<36;j++)); do
                    ps ax |grep -v grep |grep `cat $PIDFILE` > /dev/null 2>&1 || break
                    echo -n "."
                    sleep 5
                    if [ $j -gt 36 ]; then
                        echo " -- $APPNAME has not shutdown gracefully, closing $APPNAME forcefully via kill -9"
                        su - $APPUSER -c "kill -9 `cat $PIDFILE` > /dev/null 2>&1"
                    fi
                done
                if ps ax |grep -v grep |grep `cat $PIDFILE` > /dev/null 2>&1; then
                    echo " -- $APPNAME still has not shutdown, manual intervention is required -- "
                    exit 1
                else
                    echo " -- $APPNAME has shutdown"
                    rm -f ${PIDFILE}
                fi

        fi
        
        # if we run as root su to APPUSER
        if [ "$UID" == "0" ]; then
            su - $APPUSER -c "$CURRENT_SCRIPT stop"
        fi

    else
        echo "Cannot find pid at ${PIDFILE}... cannot stop $APPNAME"
        exit 1
    fi

}

status()
{
        echo "Getting status for $APPNAME"
        if [ -f $PIDFILE ]; then
            if ps ax |grep -v grep |grep `cat $PIDFILE 2>/dev/null` ; then
                echo " -- $APPNAME is running"
                exit 0
            fi
        else
            echo " -- $APPNAME is not running"
            exit 1
        fi
}

case "$1" in
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
                ;;
        *)
                echo $"Usage: $0 {start|stop|restart|status}"
                RETVAL=1
esac

