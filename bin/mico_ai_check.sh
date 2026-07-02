#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
pgrep -f "llama-server|pocketpal" > /dev/null && { log "INFO" "AI local active"; exit 0; }
log "INFO" "AI local idle"; exit 0
