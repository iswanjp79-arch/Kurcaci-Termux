#!/data/data/com.termux/files/usr/bin/bash
# MICO Optimizer — 1-Click Cleanup & Tuning (ala Advanced SystemCare)

LOG_FILE="/data/data/com.termux/files/home/JDEQ/logs/optimize.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "🚀 MICO Optimizer dimulai..."

# 1. Bersihkan log lama (>7 hari)
log "🧹 Membersihkan log lama..."
find ~/JDEQ/logs -name "*.log" -type f -mtime +7 -delete 2>/dev/null
find ~/JDEQ/logs -name "*.log.*" -type f -mtime +7 -delete 2>/dev/null

# 2. Bersihkan cache pip
log "🧹 Membersihkan pip cache..."
pip cache purge 2>/dev/null || true

# 3. Bersihkan cache apt
log "🧹 Membersihkan apt cache..."
apt clean 2>/dev/null || pkg clean 2>/dev/null || true

# 4. Hapus file temporary Termux
log "🧹 Membersihkan temporary files..."
rm -rf /data/data/com.termux/files/usr/tmp/* 2>/dev/null || true
rm -rf ~/tmp/* 2>/dev/null || true

# 5. Cek & matikan zombie process
log "🧹 Mematikan zombie process..."
pkill -f "defunct" 2>/dev/null || true

# 6. Cek RAM & swap
log "📊 Status memori:"
free -h | tee -a "$LOG_FILE"

# 7. Cek disk usage
log "📊 Status storage:"
df -h ~/ | tee -a "$LOG_FILE"

log "✅ MICO Optimizer selesai."
