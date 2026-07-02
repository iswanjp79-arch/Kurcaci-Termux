#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
LATEST=$(ls -dt "$MICO_BACKUP_DIR"/*/ 2>/dev/null | head -1)
[ -z "$LATEST" ] && { log "ERROR" "No backup found"; exit 1; }
cp -r "$LATEST/SSOT" "$MICO_SSOT_DIR" 2>/dev/null
notify "✅ Restored from $LATEST"
log "INFO" "Restored: $LATEST"; exit 0
