#!/data/data/com.termux/files/usr/bin/bash
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/event_listener.log"
DB="$QUEUE_DIR/notif.db"
HEALTH_FILE="/data/data/com.termux/files/home/JDEQ/runtime/health.json"
mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$HEALTH_FILE")"

# Trap untuk membuat recovery flag jika mati mendadak
trap 'touch /data/data/com.termux/files/home/JDEQ/runtime/recovery.flag; exit' INT TERM

while true; do
    # Trigger manual dari Tasker
    if [ -f "$QUEUE_DIR/trigger.event" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Trigger dari Tasker" >> "$LOG_FILE"
        bash ~/JDEQ/bin/notif_processor.sh
        rm -f "$QUEUE_DIR/trigger.event"
    fi

    # Health update
    echo "{\"listener\":\"running\",\"notif\":\"ok\",\"db\":\"wal\",\"last_event\":\"$(date +%s)\"}" > "$HEALTH_FILE"

    # Polling cerdas: cek notifikasi baru dalam 10 detik
    NEW_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM notif WHERE timestamp > datetime('now', '-10 seconds');" 2>/dev/null)
    if [ "$NEW_COUNT" -gt 0 ] 2>/dev/null && [ -s "$QUEUE_DIR/tts.queue" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Deteksi $NEW_COUNT notifikasi baru" >> "$LOG_FILE"
        head -n 1 "$QUEUE_DIR/tts.queue" | termux-tts-speak 2>/dev/null
        sed -i '1d' "$QUEUE_DIR/tts.queue"
    fi

    sleep 10
done
