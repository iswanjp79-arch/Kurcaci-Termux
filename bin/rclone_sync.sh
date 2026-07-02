#!/data/data/com.termux/files/usr/bin/bash
REMOTE="gdrive:JDEQ_Backup"
LOG="$HOME/JDEQ/logs/rclone.log"
echo "[$(date)] Sinkronisasi mulai" | tee -a $LOG
rclone sync $HOME/JDEQ/SSOT $REMOTE/SSOT --progress 2>&1 | tee -a $LOG
rclone sync $HOME/JDEQ/memory $REMOTE/memory --progress 2>&1 | tee -a $LOG
echo "[$(date)] Sinkronisasi selesai" | tee -a $LOG
