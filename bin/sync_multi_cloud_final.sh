#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/multi_cloud_final.log"
RCLONE_CONFIG="$HOME/JDEQ/config/rclone_multi.conf"
REMOTES=("gmail1" "gmail2" "gmail3" "gmail4" "gmail5" "gmail6" "gmail7" "gmail8" "gmail9" "gmail10" "onedrive")
TREE="$HOME/JDEQ/TREE_L"

for REMOTE in "${REMOTES[@]}"; do
  rclone --config $RCLONE_CONFIG sync $TREE $REMOTE:MICO_Fusion --progress --timeout 30s 2>&1 | tail -1 >> $LOG && \
    echo "[$(date)] ✅ $REMOTE" >> $LOG || echo "[$(date)] ⚠️ $REMOTE gagal" >> $LOG
done
echo "[$(date)] Sync selesai" >> $LOG
