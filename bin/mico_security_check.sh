#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
BROKEN=$(find ~/JDEQ -xtype l 2>/dev/null | wc -l)
WORLD_WRITABLE=$(find ~/JDEQ -perm -002 -type f 2>/dev/null | wc -l)
log "INFO" "Broken links: $BROKEN World-writable: $WORLD_WRITABLE"
[ "$WORLD_WRITABLE" -eq 0 ] || { log "WARN" "World-writable files found"; exit 2; }
exit 0
