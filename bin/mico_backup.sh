#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
DST="$MICO_BACKUP_DIR/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DST"
cp -r "$MICO_SSOT_DIR" "$DST/" 2>/dev/null
notify "✅ Backup completed: $DST"
log "INFO" "Backup: $DST"; exit 0
