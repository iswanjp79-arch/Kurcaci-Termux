#!/data/data/com.termux/files/usr/bin/bash
LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/stress_test.log"
echo "$(date) - Memulai stress test 1000 event..." > "$LOG_FILE"
for i in {1..1000}; do
    echo "Event $i dari Mas Iswan" >> /data/data/com.termux/files/home/JDEQ/queue/tts.queue
    if (( i % 100 == 0 )); then
        echo "$(date) - $i event terkirim" >> "$LOG_FILE"
    fi
    sleep 0.1
done
echo "$(date) - Stress test selesai. Cek log untuk duplicate/lost." >> "$LOG_FILE"
