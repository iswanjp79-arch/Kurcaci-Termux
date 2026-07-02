#!/data/data/com.termux/files/usr/bin/bash
# DLQ Processor – menangani task gagal
DB="/data/data/com.termux/files/home/JDEQ/dlq/dlq.db"
LOG="/data/data/com.termux/files/home/JDEQ/logs/dlq.log"
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"

while true; do
    # Ambil task pertama yang gagal (retry < 3)
    TASK=$(sqlite3 "$DB" "SELECT id, task FROM dlq WHERE retry_count < 3 ORDER BY id LIMIT 1;" 2>/dev/null | head -1)
    if [ -n "$TASK" ]; then
        ID=$(echo "$TASK" | cut -d'|' -f1)
        TASK_CMD=$(echo "$TASK" | cut -d'|' -f2)
        echo "$(date) - DLQ: Retry task $ID" >> "$LOG"
        # Kirim kembali ke queue
        echo "$TASK_CMD" >> "$QUEUE_DIR/tts.queue"
        # Update retry_count
        sqlite3 "$DB" "UPDATE dlq SET retry_count = retry_count + 1 WHERE id = $ID;"
    fi
    sleep 30
done
