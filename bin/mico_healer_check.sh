#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
crontab -l 2>/dev/null | grep -q "mico_healer.sh" && { log "INFO" "Healer in cron"; exit 0; }
[ -f ~/JDEQ/bin/mico_healer.sh ] && { log "INFO" "Healer script exists"; exit 0; }
log "WARN" "Healer not found"; exit 2
