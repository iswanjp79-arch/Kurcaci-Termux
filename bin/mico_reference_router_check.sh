#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
[ -f ~/JDEQ/CORE/reference_router/reference_router.py ] || { log "ERROR" "Router missing"; exit 1; }
log "INFO" "Router OK"; exit 0
