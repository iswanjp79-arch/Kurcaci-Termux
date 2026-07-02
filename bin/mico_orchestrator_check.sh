#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
[ -n "$MICO_ORCHESTRATOR_PID" ] && { log "INFO" "Orchestrator PID $MICO_ORCHESTRATOR_PID"; exit 0; }
log "ERROR" "Orchestrator dead"; exit 1
