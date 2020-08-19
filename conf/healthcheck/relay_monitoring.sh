#!/bin/bash

# Load functions
source /opt/devo/healthcheck/AuxFunctions.sh

# Variables
SERVICE="Relay"
export OUTPUT="/opt/devo/healthcheck/outs/${SERVICE}_monitoring.out"
export TABLE="my.app.docker.monitor.${SERVICE}.${RELAY_NAME}"

# Format
# Eventdate | Instance | Service | 0 | OK: The service is running correctly.  |
# Eventdate | Instance | Service | 1 | KO: Error Message. |

################
### PROGRAM  ###
################

if [ "$SKIPMONITORING" -eq 1 ]; then
    ### DO NOT CHECK
    send2devo "${SERVICE}" "SKIPMONITORING" "Monitoring skipped" "${RELAY_NAME}" "localhost"
    exit 0
else
    ### DO CHECK
    reset_res_vars
    ps_found "scoja.jar"
    ps_found "cron"
    pt_found 12999
    pt_found 13000
    pt_found 13001
    pt_found 13002
    ps_resul "${SERVICE}" "${RELAY_NAME}" "localhost"
    exit 0
fi

# Always exit 0 to avoid container set to unhealthy
exit 0
