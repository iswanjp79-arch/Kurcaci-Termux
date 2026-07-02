#!/data/data/com.termux/files/usr/bin/bash
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"
LOCK_FILE="$QUEUE_DIR/queue.lock"
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/tts_worker.log"
exec 200>$LOCK_FILE
while true; do
    flock -x 200
    FILE=$(ls -1rt "$QUEUE_DIR"/*.txt 2>/dev/null | head -n 1)
    if [ -n "$FILE" ]; then
        echo "$(date) - Memproses $FILE" >> "$LOG_FILE"
        cat "$FILE" | termux-tts-speak 2>/dev/null
        rm "$FILE"
    fi
    flock -u 200
    sleep 2
done
