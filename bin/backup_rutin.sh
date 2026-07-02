#!/data/data/com.termux/files/usr/bin/bash
BACKUP_BASE=~/JDEQ_BACKUP
MAX_BACKUPS=3

# Buat backup baru
TIMESTAMP=$(date +%Y%m%d_%H%M)
BACKUP_DIR="$BACKUP_BASE/backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# Salin SSOT dan file penting
rsync -av --exclude='*.gguf' --exclude='models/' ~/JDEQ/SSOT/ "$BACKUP_DIR/SSOT/" 2>/dev/null
cp ~/JDEQ/config/*.json "$BACKUP_DIR/config/" 2>/dev/null
cp ~/JDEQ/MICO_LIFECYCLE/mico_state.db "$BACKUP_DIR/" 2>/dev/null
crontab -l > "$BACKUP_DIR/crontab.txt" 2>/dev/null

echo "$(date): Backup created: $BACKUP_DIR" >> ~/JDEQ/logs/backup.log

# Rotasi: simpan hanya 5 versi terakhir
BACKUP_COUNT=$(ls -dt "$BACKUP_BASE"/backup_* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    ls -dt "$BACKUP_BASE"/backup_* | tail -n +$((MAX_BACKUPS+1)) | xargs rm -rf
    echo "$(date): Rotated old backups (max $MAX_BACKUPS)" >> ~/JDEQ/logs/backup.log
fi
