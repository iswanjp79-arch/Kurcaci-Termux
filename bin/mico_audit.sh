#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
echo "MICO-JDEQ AUDIT $(date)" > "$MICO_LOG_DIR/audit.log"
for chk in kernel ssot reference_router orchestrator healer cron storage performance security ai cloud backup restore; do
    script="$BIN/mico_${chk}_check.sh"
    [ -f "$script" ] && bash "$script" >> "$MICO_LOG_DIR/audit.log" 2>&1
done
echo "Audit completed"
