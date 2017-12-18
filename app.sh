#!/bin/bash
 
HOME=/home/tiep
APP_HOME="$HOME/apps/deal-booking/"
LOG_FILE="$HOME/logs/deal-booking.log"
PIDFILE="$APP_HOME/deal-booking.pid"
MAX_MEMORY="512M"
JAVA_8=/opt/app/jdk1.8.0_141
JARFile="$APP_HOME/deal-booking.jar"
ENV="$2"
JAVA_OPTS="-Xmx$MAX_MEMORY -Dspring.profiles.active=$ENV"
 
 
function start {
  if [ "$ENV" = "" ]; then
    echo "Please specify the environment (dev, uat, prod) to start."
    return 1
  fi
 
  if [ -f $PIDFILE ] ; then
    pid=$(ps -ef | grep "$(cat $PIDFILE)" | grep -v grep | awk '{print$2}')
 
    if [ "$pid" != "" ]; then
      echo 'Service is already running at' "$pid" >&2
      return 1
    else
      echo 'PIDFILE exists but there is no process running at' "$(cat $PIDFILE)" >&2
      echo 'Remove PIDFILE and continue'
      rm -f "$PIDFILE"
    fi
  fi
  echo 'Starting service' >&2
 
  nohup $JAVA_8/bin/java $JAVA_OPTS -jar $JARFile > /dev/null 2>&1 &
  #nohup $JAVA_8/bin/java $JAVA_OPTS -jar $JARFile > console.out 2>&1 &
  echo $! > $PIDFILE
 
  echo 'Service started at' "$(cat $PIDFILE)" >&2
}
 
function stop {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(<"$PIDFILE"); then
    echo 'Service not running' >&2
    rm -f "$PIDFILE"
    return 0
  fi
  echo 'Stopping service' >&2
  kill -15 $(<"$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}
 
function status {
  if [ -f $PIDFILE ] ;then
    echo 'Service is running at' "$(cat $PIDFILE)" >&2
    return 0
  fi
 
  echo 'Service is not started'
}
  
function log {
  tail -500f $LOG_FILE
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
    sleep 2
    start
    ;;
  status)
    status
    ;;
  log)
    log
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
esac
