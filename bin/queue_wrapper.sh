#!/data/data/com.termux/files/usr/bin/bash
# Menggunakan flock untuk mengamankan queue
QUEUE_DIR="/data/data/com.termux/files/home/JDEQ/queue"
LOCK_FILE="$QUEUE_DIR/queue.lock"

exec 200>$LOCK_FILE
flock -x 200
# eksekusi perintah queue di sini
flock -u 200
