#!/data/data/com.termux/files/usr/bin/bash
# MICO JDEQ — Backup Overwrite (Hemat Storage)
# Hanya menyimpan 1 salinan terbaru, menimpa yang lama
LOG="$HOME/JDEQ/logs/backup_ow_$(date +%Y%m%d).log"
BACKUP_DIR="$HOME/JDEQ/backup/overwrite"

echo "[$(date '+%H:%M:%S')] Memulai backup overwrite..." | tee -a $LOG

# Hapus backup lama
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Salin folder inti (overwrite)
for DIR in SSOT CONSTITUTION CORTEX DAL SECURITY GOVERNANCE; do
  if [ -d "$HOME/JDEQ/$DIR" ]; then
    cp -r "$HOME/JDEQ/$DIR" "$BACKUP_DIR/$DIR" 2>/dev/null
    echo "  ✅ $DIR" | tee -a $LOG
  else
    echo "  ⚠️ $DIR tidak ditemukan" | tee -a $LOG
  fi
done

# Tampilkan ukuran backup
SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "[$(date '+%H:%M:%S')] Backup selesai. Ukuran: $SIZE" | tee -a $LOG
echo "✅ Backup overwrite tersimpan di $BACKUP_DIR"
