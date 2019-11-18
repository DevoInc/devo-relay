#!/bin/bash

. /etc/profile

if [ -f /opt/devo/relay-data/selfsigned ]; then
  export PYTHONHTTPSVERIFY=0
fi

export TZ=UTC

export LOGTRUST_HOME=${LOGTRUST_HOME:-/opt/logtrust}
export LOGTRUST_CONF=${LOGTRUST_CONF:-/etc/logtrust}

$LOGTRUST_HOME/relay/UpdateRelay.py  > /var/log/lt-relay.log 2>&1

if [ -s $LOGTRUST_CONF/scoja/current/config-relay.tar ]
then
        tar  -C $LOGTRUST_CONF/scoja/current/ -xf $LOGTRUST_CONF/scoja/current/config-relay.tar
        rm -f $LOGTRUST_CONF/scoja/current/config-relay.tar

        if [ -f $LOGTRUST_CONF/scoja/current/pass.temp ]; then
          newpass=`cat $LOGTRUST_CONF/scoja/current/pass.temp |cut -d"=" -f2|sed 's/\//'"\\\\\\\\\/"'/g'`
          sed -i -e 's/keypass = \".*\"/keypass = \"'"${newpass}"'\"/' $LOGTRUST_CONF/scoja/current/local.py
          cp /etc/logtrust/scoja/current/pass.temp /opt/devo/relay-data
          rm -f $LOGTRUST_CONF/scoja/current/pass.temp
          touch $LOGTRUST_CONF/scoja/current/*.conf
        else
          touch $LOGTRUST_CONF/scoja/current/all-var.conf
        fi
fi

echo "Cron ok: `date`" > /var/log/cron_alive.log
