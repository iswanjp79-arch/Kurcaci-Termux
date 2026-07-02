#!/data/data/com.termux/files/usr/bin/bash
LOG=~/JDEQ/KERNEL/logs/watchdog.log
LAST_INDEX=0
COOLDOWN=300  # 5 menit

while true; do
    NOW=$(date +%s)
    
    # Kernel Daemon
    if ! pgrep -f kernel_daemon.py > /dev/null; then
        echo "[$(date)] Kernel Daemon mati — membangunkan..." >> $LOG
        python3 ~/JDEQ/KERNEL/daemon/kernel_daemon.py &
    fi
    
    # Index Daemon — hanya jika cooldown terpenuhi
    if [ $((NOW - LAST_INDEX)) -ge $COOLDOWN ]; then
        if ! pgrep -f index_daemon.py > /dev/null; then
            echo "[$(date)] Index Daemon — membangun indeks..." >> $LOG
            python3 ~/JDEQ/KERNEL/daemon/index_daemon.py &
            LAST_INDEX=$NOW
        fi
    fi
    
    # Mosquitto
    if ! pgrep -x mosquitto > /dev/null; then
        echo "[$(date)] Mosquitto mati — membangunkan..." >> $LOG
        mosquitto -d
    fi
    
    sleep 10
done
