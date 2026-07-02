#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
[ -f "$MICO_SSOT_DIR/EVENT_TYPES.json" ] || { log "ERROR" "SSOT missing"; exit 1; }
PERM=$(stat -c "%a" "$MICO_SSOT_DIR/EVENT_TYPES.json")
[ "$PERM" = "444" ] || [ "$PERM" = "500" ] || { log "WARN" "SSOT permission $PERM"; exit 2; }
log "INFO" "SSOT OK"; exit 0
