#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/multi_cloud_sync.log"
RCLONE_CONFIG="$HOME/JDEQ/config/rclone_multi.conf"
REMITES=("gmail1" "gmail2" "gmail3" "gmail4" "gmail5" "gmail6" "gmail7" "gmail8" "gmail9" "gmail10" "onedrive")
TREE="$HOME/JDEQ/TREE_L"

for REMOTE in "${REMITES[@]}"; do
  echo "[$(date)] Sinkronisasi ke $REMOTE" >> $LOG
  rclone --config $RCLONE_CONFIG sync $TREE $REMOTE:MICO_Tree_L --progress --timeout 30s 2>&1 | tail -1 >> $LOG
  if [ $? -eq 0 ]; then
    echo "  ✅ $REMOTE sukses" >> $LOG
  else
    echo "  ⚠️ $REMOTE gagal (mungkin belum auth)" >> $LOG
  fi
done

# Sinkronisasi ke Infinix via SSH
ssh -p 8022 -o ConnectTimeout=5 100.103.39.81 "mkdir -p ~/JDEQ_CLONE/TREE_L" 2>/dev/null && \
  rsync -avz -e "ssh -p 8022" $TREE/ 100.103.39.81:~/JDEQ_CLONE/TREE_L/ 2>&1 | tail -1 >> $LOG && \
  echo "[$(date)]  ✅ Infinix sync sukses" >> $LOG || \
  echo "[$(date)]  ⚠️ Infinix sync gagal" >> $LOG

# Sinkronisasi ke Colab (jika ada endpoint)
# curl -X POST http://colab-ip:8082/sync -d @$TREE/manifest.json 2>/dev/null
echo "[$(date)] Sync selesai" >> $LOG
