#!/bin/bash
source ~/JDEQ/bin/mico_lib.sh
if command -v rclone > /dev/null; then
    rclone lsd BRANKAS_UTAMA: > /dev/null 2>&1 && { log "INFO" "Cloud OK"; exit 0; }
    log "WARN" "rclone installed but remote not reachable"
    exit 0  # WARN bukan FAIL
fi
log "INFO" "rclone not installed — cloud sync deferred"
exit 0  # Not a failure, just not configured
