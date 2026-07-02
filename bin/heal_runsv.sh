#!/bin/bash
# Auto-healer untuk runsv lock
LOCK_FILE=$(find ~ -path "*/mico-daemon/supervise/lock" 2>/dev/null)
if [ -n "$LOCK_FILE" ]; then
    pkill -9 -f "runsv mico-daemon" 2>/dev/null
    rm -f "$LOCK_FILE"
    echo "[$(date)] Lock runsv dibersihkan." >> ~/JDEQ/logs/healer.log
fi
