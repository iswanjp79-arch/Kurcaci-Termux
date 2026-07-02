#!/data/data/com.termux/files/usr/bin/bash
# Backup ringan dari /sdcard/JDEQ_SYSTEM_LOCK ke Google Drive (gdrive)

LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/backup_rclone.log"
SOURCE="/sdcard/JDEQ_SYSTEM_LOCK"
DEST="gdrive:JDEQ_Backup"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if ! command -v rclone &> /dev/null; then
    log "❌ Rclone tidak ditemukan."
    exit 1
fi

if [ ! -d "$SOURCE" ]; then
    log "❌ Folder $SOURCE tidak ditemukan. Buat dulu: mkdir -p $SOURCE"
    exit 1
fi

log "🔄 Mulai backup ke $DEST"
rclone sync "$SOURCE" "$DEST" --progress --stats-one-line 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    log "✅ Backup selesai."
else
    log "❌ Backup gagal."
fi

pkill -f "rclone" 2>/dev/null || true
log "✅ Selesai."
