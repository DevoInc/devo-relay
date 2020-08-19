#!/bin/bash

. /etc/profile

############
## Logs writer and sender to barasiogen 1514 for incron inotify events
############
# Priority = Facility * 8 + Level
# 78 = 9 (cron/clock) * 8 + 6 (info)
############
# echo "<78>Aug 07 23:24:01 devo-manager-incron my.app.docker.handlobo: oneRun.sh|Jan 20 04:24:01 UTC 1975|manager-lobo|serviceCreated=Devo" | nc batrasiogen 1514 -q 0
############

############
## HOWTO:
# $1 = name of process who calls logs.sh
# $2 = message
# $3 = syslog Devo table
# $4 = batrasio to send events
############

TZ=UTC
LOGDIR=/var/log/incron
SU_USER="logtrust"
export TZ LOGDIR SU_USER

processCalling=$1
messageReceived=$2
syslogDevoTable=$3
syslogDevo=${4:-batrasiogen}

logFile=incron-$(hostname).log
eldia=$(date "+%d")
elmes=$(date "+%b")
lahora=$(date "+%H:%M:%S")

#echo "<78>$elmes $eldia $lahora devo-manager-incron $syslogDevoTable: $processCalling|`date`|`hostname`|$messageReceived" > $LOGDIR/$logFile
(echo "<78>$elmes $eldia $lahora devo-manager-incron $syslogDevoTable: $processCalling|`date`|`hostname`|$messageReceived" | nc -N $syslogDevo 13000 -q 0)

### END
