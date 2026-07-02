#!/data/data/com.termux/files/usr/bin/bash
# Sinkronisasi ke cloud hanya jika jaringan tersedia dan aman
CLOUD_REMOTE="gdrive:Backup_Platform_AI"
LOG=~/JDEQ/logs/cloud_sync.log

# Cek koneksi internet
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    # Cek apakah rclone terkonfigurasi
    if command -v rclone > /dev/null && rclone listremotes 2>/dev/null | grep -q "gdrive:"; then
        echo "$(date): Cloud sync started" >> "$LOG"
        rclone copy ~/JDEQ/SSOT "$CLOUD_REMOTE/SSOT" --transfers 1 --verbose >> "$LOG" 2>&1
        rclone copy ~/JDEQ/config "$CLOUD_REMOTE/config" --transfers 1 --verbose >> "$LOG" 2>&1
        echo "$(date): Cloud sync completed" >> "$LOG"
    else
        echo "$(date): rclone not configured, skipping" >> "$LOG"
    fi
else
    echo "$(date): No internet, skipping cloud sync" >> "$LOG"
fi
