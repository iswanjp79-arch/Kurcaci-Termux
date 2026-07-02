#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/close_gaps_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "===== MENUTUP CELAH DEWAN AGEN ====="

# 1. Verifikasi Intent Graph
if [ -f ~/JDEQ/CORTEX/intent_graph.py ]; then
  stamp "✅ Intent Graph sudah ada"
  # Tambahkan aturan baru jika belum ada
  if ! grep -q "kirim|pesan|chat" ~/JDEQ/CORTEX/intent_graph.py 2>/dev/null; then
    stamp "🔧 Menambah aturan Intent baru..."
    sed -i 's/}$/,\n    "kirim|pesan|chat|tulis": {"intent": "SEND_MESSAGE", "capability": "message_sender", "response": "Baik, mengirim pesan."}\n}/' ~/JDEQ/CORTEX/intent_graph.py 2>/dev/null || true
  fi
else
  stamp "⚠️ Intent Graph tidak ditemukan — buat ulang dari bundle build_next_10.sh"
fi

# 2. Verifikasi Sensor Bridge
if [ -f ~/JDEQ/bridge/macro_listener.sh ]; then
  stamp "✅ Macro Listener bridge sudah ada"
else
  stamp "🔧 Membuat ulang Macro Listener bridge..."
  mkdir -p ~/JDEQ/bridge
  cat > ~/JDEQ/bridge/macro_listener.sh << 'BRIDGEEOF'
#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/camera_trigger.log"
echo "[$(date)] Sinyal diterima: $1" >> $LOG
if [ "$1" = "capture" ]; then
  LAST_FILE=$(ls -t /storage/emulated/0/MICO_Capture/*.jpg 2>/dev/null | head -1)
  if [ -n "$LAST_FILE" ]; then
    echo "✅ Foto terdeteksi: $LAST_FILE" >> $LOG
    bash ~/JDEQ/bin/notify_telegram.sh "📷 MICO: Foto baru diterima" 2>/dev/null
  fi
fi
BRIDGEEOF
  chmod +x ~/JDEQ/bridge/macro_listener.sh
fi

# 3. Jalankan audit ulang
stamp ""
stamp "===== AUDIT ULANG ====="
bash ~/JDEQ/bin/audit_dewan_agen.sh

stamp "===== CELAH DITUTUP ====="
