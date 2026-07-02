#!/data/data/com.termux/files/usr/bin/bash
# JDEQ Sync Engine – menggunakan remote G01 (Google Drive utama)

LOG_FILE="$HOME/JDEQ/logs/sync_jdeq.log"
REMOTE="G01:JDEQ_SSOT"
LOCAL="$HOME/JDEQ/ssot"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

if ! command -v rclone &> /dev/null; then
  log "❌ Rclone tidak ditemukan. Install: pkg install rclone"
  exit 1
fi

# Cek koneksi internet
ping -c 1 8.8.8.8 &> /dev/null || { log "❌ Tidak ada koneksi internet."; exit 1; }

log "🔄 Mulai sync dari $REMOTE ke $LOCAL"
rclone sync "$REMOTE" "$LOCAL" --progress --stats-one-line 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
  log "✅ Sync selesai."
else
  log "❌ Sync gagal (exit code $?)."
  exit 1
fi
