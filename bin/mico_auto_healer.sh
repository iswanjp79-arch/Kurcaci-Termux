#!/bin/bash
# MICO AUTO-HEALER — Vivo Y28
# Dokter utama kawasan. Menyimpan salinan lengkap sistem.

PORT_HEALER=8888
HEALER_LOG=~/JDEQ/logs/auto_healer.log
BUNDLE_DIR=~/JDEQ_BUNDLE_PENUH

echo "[$(date)] 🩺 Auto-Healer MICO (Vivo) dimulai..." >> "$HEALER_LOG"

# 1. Pastikan bundle pack selalu tersedia (update setiap 1 jam)
while true; do
  mkdir -p "$BUNDLE_DIR"/{SSOT,bin,AUDIT,KERNEL,CORE,SECURITY}
  cp -r ~/JDEQ/SSOT/* "$BUNDLE_DIR/SSOT/" 2>/dev/null
  cp -r ~/JDEQ/bin/*.sh "$BUNDLE_DIR/bin/" 2>/dev/null
  cp -r ~/JDEQ/KERNEL/* "$BUNDLE_DIR/KERNEL/" 2>/dev/null
  cp -r ~/JDEQ/CORE/* "$BUNDLE_DIR/CORE/" 2>/dev/null
  cp -r ~/JDEQ/SECURITY/* "$BUNDLE_DIR/SECURITY/" 2>/dev/null

  # Buat installer otomatis
  cat > "$BUNDLE_DIR/install.sh" << 'INSTALLER'
#!/bin/bash
echo "🔄 MEMULIHKAN MICO DARI CADANGAN VIVO..."
mkdir -p ~/JDEQ
cp -r ./* ~/JDEQ/
chmod +x ~/JDEQ/bin/*.sh 2>/dev/null
bash ~/JDEQ/bin/mico_boot.sh
echo "✅ PEMULIHAN SELESAI — MICO HIDUP KEMBALI"
INSTALLER
  chmod +x "$BUNDLE_DIR/install.sh"

  echo "[$(date)] ✅ Bundle pack Vivo diperbarui" >> "$HEALER_LOG"
  sleep 3600
done &

# 2. Dengarkan permintaan pemulihan dari perangkat baru
while true; do
  echo "[$(date)] 👂 Vivo mendengarkan permintaan pemulihan di port $PORT_HEALER..." >> "$HEALER_LOG"
  nc -l -p "$PORT_HEALER" -c 'tar czf - ~/JDEQ_BUNDLE_PENUH/ 2>/dev/null' 2>/dev/null
  echo "[$(date)] 📦 Bundle pack dikirim ke perangkat baru" >> "$HEALER_LOG"
done
