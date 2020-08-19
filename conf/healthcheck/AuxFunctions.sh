#!/bin/bash

################
### FUNTIONS ###
################

# Send events to Devo with the monitoring status
function send2devo {
    service=$1
    status_code=$2
    status_text=$3
    instance=$4
    collector=${5:-batrasiogen}

    MESSAGE="$(date "+%F_%T")|${instance}|${service}|${status_code}|${status_text}"
    (echo "${MESSAGE}" > "${OUTPUT}")
    (/opt/devo/healthcheck/sendlogs.sh "$(hostname)_monitoring" "${MESSAGE}" "${TABLE}" "${collector}")
}

# Reset variables on each execution of the monitor
function reset_res_vars {
    RES_NUM=0
    RES_TXT=""
}

# Check if the process is running
function ps_found {
    if ! (pgrep -af "$1") > /dev/null 2>&1
    then
       RES_NUM=1
       RES_TXT="$RES_TXT No process $1 found running."
    fi
}

# Check systemd status
function sy_found {
    if ! (systemctl status "$1") > /dev/null 2>&1
    then
       RES_NUM=1
       RES_TXT="$RES_TXT Systemctl $1 reports issues."
    fi
}

# Check port listening
function pt_found {
    if ! (netstat -lnp | grep :"$1") > /dev/null 2>&1
    then
       RES_NUM=1
       RES_TXT="$RES_TXT No port $1 found listening."
    fi
}

# Check service healthchheck endpoint status
function ep_found {
    if (curl -skL "$1"/system/healthcheck | python -c 'import sys, json; print json.load(sys.stdin).keys()') > /dev/null 2>&1
    then
        for HEALTH_POINT in $(curl -skL "$1"/system/healthcheck | python -c "exec(\"import sys, json\nmydict=json.load(sys.stdin).keys()\nfor x in range(len(mydict)): print mydict[x]\")")
        do
            if ! (curl -skL "$1"/system/healthcheck | python -c 'import sys, json; print json.load(sys.stdin)["'"${HEALTH_POINT}"'"]["healthy"]' | grep -i true) > /dev/null 2>&1
            then
                RES_NUM=1
                RES_TXT="$RES_TXT No healthy status in ${HEALTH_POINT} endpoint."
            fi
        done
    else
        RES_NUM=1
        RES_TXT="$RES_TXT Health status endpoint reports issues."
    fi
}

# Check website return code status
function web_found {
    STATUS=$(curl -sk -o /dev/null -w '%{http_code}' "$1")
    if [ "${STATUS}" -ne 200 ]
    then
        RES_NUM=1
        RES_TXT="$RES_TXT $1 endpoint reports issues."
    fi
}

# Set the service status and reports
function ps_resul {
    service=$1
    instance=$2
    collector=${3:-batrasiogen}

    if [ $RES_NUM -eq 0 ]
    then
        send2devo "${service}" "${RES_NUM}" "OK: ${service} is running correctly." "${instance}" "${collector}"
    else
        send2devo "${service}" "${RES_NUM}" "KO: ${RES_TXT}" "${instance}" "${collector}"
    fi
}
