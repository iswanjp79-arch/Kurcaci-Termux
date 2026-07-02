#!/data/data/com.termux/files/usr/bin/bash
RECOVERY_FLAG="/data/data/com.termux/files/home/JDEQ/runtime/recovery.flag"
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/recovery.log"
if [ -f "$RECOVERY_FLAG" ]; then
    echo "$(date) - Recovery triggered!" >> "$LOG_FILE"
    if [ -f "$QUEUE_DIR/tts.queue" ]; then
        mv "$QUEUE_DIR/tts.queue" "$QUEUE_DIR/tts.queue.bak.$(date +%s)"
        echo "$(date) - Queue dibackup" >> "$LOG_FILE"
    fi
    rm -f "$RECOVERY_FLAG"
    pkill -f "event_listener.sh" 2>/dev/null || true
    sleep 1
    nohup ~/JDEQ/bin/event_listener.sh > /dev/null 2>&1 &
    echo "$(date) - Listener direstart" >> "$LOG_FILE"
fi
