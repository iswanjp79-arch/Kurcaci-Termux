#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
# Cek apakah crond berjalan
pgrep -x crond > /dev/null && { log "INFO" "Cron daemon active"; exit 0; }
# Atau cek apakah ada crontab untuk user ini
crontab -l 2>/dev/null | grep -q "mico_healer" && { log "INFO" "Cron jobs configured"; exit 0; }
# Fallback: healer berjalan di background
pgrep -f "mico_healer.sh" > /dev/null && { log "INFO" "Healer running in background (cron fallback)"; exit 0; }
log "WARN" "No cron or healer detected"
exit 2
