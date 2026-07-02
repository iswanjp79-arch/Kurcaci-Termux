#!/bin/bash
STATE_FILE=~/JDEQ/AUDIT/last_infinix_state
CHECK_INTERVAL=180
INFINIX_IP="100.103.39.81"   # IP Tailscale Infinix

while true; do
    if ping -c 1 -W 3 "$INFINIX_IP" > /dev/null 2>&1; then
        NEW_STATE="ONLINE"
    else
        NEW_STATE="OFFLINE"
    fi

    OLD_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "INIT")
    if [ "$NEW_STATE" != "$OLD_STATE" ]; then
        echo "$NEW_STATE" > "$STATE_FILE"
        ~/JDEQ/bin/send_telegram.sh "📡 STATUS INFINIX: $NEW_STATE"
    fi
    sleep "$CHECK_INTERVAL"
done
