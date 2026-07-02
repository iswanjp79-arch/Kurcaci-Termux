#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/auto_sync.log"
echo "[$(date)] Sinkronisasi dimulai" >> $LOG
rclone sync ~/JDEQ/symlinks gdrive:MICO_Symlinks --progress 2>&1 | tee -a $LOG
rclone sync ~/JDEQ/SSOT mega:MICO_SSOT --progress 2>&1 | tee -a $LOG
echo "[$(date)] Sinkronisasi selesai" >> $LOG
