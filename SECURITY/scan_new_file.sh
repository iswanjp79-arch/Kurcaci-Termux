#!/data/data/com.termux/files/usr/bin/bash
DIR_MONITOR="$HOME/JDEQ/incoming"
LOG_SCAN="$HOME/JDEQ/logs/scan.log"
mkdir -p "$DIR_MONITOR" "$HOME/JDEQ/processed" "$(dirname "$LOG_SCAN")"
echo "[$(date)] Memulai pemindaian..." >> "$LOG_SCAN"
for file in "$DIR_MONITOR"/*; do
  [ -e "$file" ] || continue
  if grep -qE "eval\(|base64_decode|union select|rm -rf" "$file" 2>/dev/null; then
    echo "🚨 BERKAS BERBAHAYA: $file - DIHAPUS" >> "$LOG_SCAN"
    rm "$file"
  else
    echo "✅ Berkas aman: $file" >> "$LOG_SCAN"
    mv "$file" "$HOME/JDEQ/processed/" 2>/dev/null || true
  fi
done
echo "[$(date)] Pemindaian selesai." >> "$LOG_SCAN"
