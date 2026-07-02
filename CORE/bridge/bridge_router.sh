#!/bin/bash
JDEQ="/data/data/com.termux/files/home/JDEQ"
AUDIT="$JDEQ/CORE_MEMORY/logs/audit.log"
log() { echo "$(date '+%F %T') | BRIDGE | $1 | $2" >> "$AUDIT"; }

action="$1"
shift
case "$action" in
    ping)
        echo "pong"
        log "PING" "pong"
        ;;
    run)
        # Contoh: bridge run rab -> jalankan di Termux via gateway
        echo "$*" | bash "$JDEQ/mico_gateway.sh"
        log "RUN" "$*"
        ;;
    status)
        echo "Bridge : ACTIVE"
        bash "$JDEQ/CORE_BRIDGE/env_check.sh"
        ;;
    *)
        echo "Bridge commands: ping, run <module>, status"
        ;;
esac
