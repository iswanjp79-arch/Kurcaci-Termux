#!/data/data/com.termux/files/usr/bin/bash
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"
DB="$QUEUE_DIR/notif.db"
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/notif_processor.log"
mkdir -p "$(dirname "$LOG_FILE")"
process_notif() {
    local sender="$1"
    local content="$2"
    local HASH=$(echo "$sender$content" | md5sum | cut -d' ' -f1)
    if ! sqlite3 "$DB" "SELECT hash FROM notif WHERE hash='$HASH';" 2>/dev/null | grep -q .; then
        sqlite3 "$DB" "INSERT INTO notif (sender, content, hash) VALUES ('$sender', '$content', '$HASH');"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - NOTIF BARU: $sender" >> "$LOG_FILE"
        echo "$content" >> "$QUEUE_DIR/tts.queue"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - DUPLIKAT: $sender" >> "$LOG_FILE"
    fi
}
