#!/bin/bash
# Backup JDEQ ke semua remote GDrive (G01–G10)

REMOTES="G01 G02 G03 G04 G05 G06 G07 G08 G09 G10"
SOURCE="$HOME/JDEQ"
LOG_FILE="$HOME/JDEQ/logs/backup_multi_cloud.log"

echo "============================================================" | tee -a "$LOG_FILE"
echo "  BACKUP MULTI-CLOUD – $(date)" | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"

for R in $REMOTES; do
  echo "📤 Backup ke $R:JDEQ_BACKUP ..." | tee -a "$LOG_FILE"
  rclone copy "$SOURCE" "$R:JDEQ_BACKUP" --progress --transfers 2 --stats-one-line 2>&1 | tee -a "$LOG_FILE"
  if [ $? -eq 0 ]; then
    echo "✅ Backup ke $R selesai" | tee -a "$LOG_FILE"
  else
    echo "❌ Backup ke $R gagal" | tee -a "$LOG_FILE"
  fi
  echo "" | tee -a "$LOG_FILE"
done

echo "============================================================" | tee -a "$LOG_FILE"
echo "  BACKUP SELESAI – $(date)" | tee -a "$LOG_FILE"
