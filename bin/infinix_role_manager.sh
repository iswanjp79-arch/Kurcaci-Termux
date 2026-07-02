#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/infinix_role_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp "  INFINIX ROLE MANAGER — 30 Juni 2026"
stamp "  Menyesuaikan peran Infinix 32-bit"
stamp "============================================"

# ============================================================
# ANALISIS KONDISI INFINIX SAAT INI
# ============================================================
stamp ""
stamp "===== DIAGNOSA INFINIX ====="

INFINIX_IP="100.103.39.81"
INFINIX_ONLINE=0

# Cek koneksi
if ping -c 1 -W 2 $INFINIX_IP > /dev/null 2>&1; then
  stamp "✅ Infinix terjangkau via jaringan"
  
  # Cek server Symthink (port 9000)
  if curl -s --max-time 5 -X POST http://$INFINIX_IP:9000 -d '{"cmd":"echo alive"}' 2>/dev/null | grep -q "alive"; then
    stamp "✅ Server Symthink Infinix AKTIF"
    INFINIX_ONLINE=1
  else
    stamp "⚠️ Server Symthink Infinix MATI — coba nyalakan via SSH"
    ssh -o ConnectTimeout=5 -p 8022 $INFINIX_IP "cd ~/JDEQ_CLONE/server && nohup python3 mico_server.py > /dev/null 2>&1 &" 2>/dev/null
    sleep 3
    if curl -s --max-time 5 -X POST http://$INFINIX_IP:9000 -d '{"cmd":"echo alive"}' 2>/dev/null | grep -q "alive"; then
      stamp "✅ Server Symthink berhasil dinyalakan"
      INFINIX_ONLINE=1
    else
      stamp "⚠️ Server Symthink gagal dinyalakan — perlu akses manual ke Infinix"
    fi
  fi
  
  # Cek SSH
  if ssh -o ConnectTimeout=3 -p 8022 $INFINIX_IP "echo ssh_ok" 2>/dev/null | grep -q "ssh_ok"; then
    stamp "✅ SSH Infinix AKTIF"
  else
    stamp "⚠️ SSH Infinix tidak responsif"
  fi
else
  stamp "❌ Infinix TIDAK TERJANGKAU — nyalakan WiFi/Hotspot"
fi

# ============================================================
# PENYESUAIAN PERAN INFINIX (32-bit, RAM 2GB)
# ============================================================
stamp ""
stamp "===== PENYESUAIAN PERAN INFINIX ====="

# Definisi peran yang cocok untuk Infinix 32-bit
cat > ~/JDEQ/config/infinix_role.json << 'ROLEJSON'
{
  "device": "Infinix 32-bit",
  "ram": "2GB",
  "storage": "32GB",
  "assigned_roles": {
    "primary": [
      "STORAGE_NODE",       # Penyimpanan cadangan (SSOT mirror, backup)
      "RELAY_SERVER",       # Meneruskan perintah dari luar ke Vivo
      "SYMTHINK_VERIFIER"   # Verifikasi hasil penalaran Vivo
    ],
    "secondary": [
      "MQTT_BROKER",        # Broker komunikasi ringan
      "AUDIT_MIRROR",       # Salinan audit trail
      "LOG_ARCHIVE"         # Arsip log jangka panjang
    ],
    "prohibited": [
      "LLM_INFERENCE",      # Tidak cukup RAM untuk LLM
      "DECISION_KERNEL",    # Keputusan hanya di Vivo
      "SENSOR_PROCESSING"   # Tidak ada sensor canggih
    ]
  },
  "sync_schedule": {
    "ssot_mirror": "*/15 * * * *",
    "audit_sync": "*/30 * * * *",
    "log_archive": "0 * * * *"
  },
  "network": {
    "allowed_connections": ["100.123.232.84", "100.103.39.81"],
    "ports": [8000, 8022, 9000]
  }
}
ROLEJSON
chmod 444 ~/JDEQ/config/infinix_role.json
stamp "✅ Peran Infinix dikunci: Storage + Relay + Verifier"

# ============================================================
# IMPLEMENTASI: SINKRONISASI OTOMATIS
# ============================================================
stamp ""
stamp "===== AKTIVASI SINKRONISASI ====="

# Buat skrip sinkronisasi SSOT ke Infinix
cat > ~/JDEQ/bin/sync_to_infinix.sh << 'SYNCSCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
INFINIX_IP="100.103.39.81"
LOG="$HOME/JDEQ/logs/sync_infinix.log"

# Sinkronkan SSOT
rsync -az --delete ~/JDEQ/SSOT/ ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/SSOT/ 2>/dev/null && \
  echo "[$(date)] ✅ SSOT tersinkron" >> $LOG || \
  echo "[$(date)] ⚠️ Infinix tidak terjangkau" >> $LOG

# Sinkronkan audit trail
rsync -az ~/JDEQ/logs/audit_*.log ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/logs/ 2>/dev/null

# Sinkronkan config
rsync -az ~/JDEQ/config/ ${INFINIX_IP}:~/JDEQ_CLONE/MIRROR/config/ 2>/dev/null
SYNCSCRIPT
chmod +x ~/JDEQ/bin/sync_to_infinix.sh

# Jadwalkan sinkronisasi
(crontab -l 2>/dev/null | grep -v sync_to_infinix; echo "*/15 * * * * bash ~/JDEQ/bin/sync_to_infinix.sh") | crontab -
stamp "✅ Sinkronisasi SSOT → Infinix terjadwal (15 menit)"

# ============================================================
# VERIFIKASI AKHIR
# ============================================================
stamp ""
stamp "============================================"
stamp "  STATUS INFINIX"
stamp "============================================"

if [ $INFINIX_ONLINE -eq 1 ]; then
  # Cek kapasitas Infinix
  INF_RAM=$(curl -s --max-time 5 -X POST http://$INFINIX_IP:9000 \
    -d '{"cmd":"free -m | awk '\''/Mem/{print $7}'\''"}' 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('result','N/A').strip())" 2>/dev/null)
  INF_DISK=$(curl -s --max-time 5 -X POST http://$INFINIX_IP:9000 \
    -d '{"cmd":"df -h ~ | awk '\''NR==2 {print $5}'\''"}' 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('result','N/A').strip())" 2>/dev/null)
  
  echo "✅ Infinix ONLINE" | tee -a $LOG
  echo "   RAM bebas : ${INF_RAM:-N/A} MB" | tee -a $LOG
  echo "   Disk      : ${INF_DISK:-N/A}" | tee -a $LOG
  echo "   Peran     : Storage Node + Relay Server + Symthink Verifier" | tee -a $LOG
  echo "   Terlarang : LLM Inference, Decision Kernel, Sensor Processing" | tee -a $LOG
else
  echo "⚠️ Infinix OFFLINE — peran akan aktif saat terhubung" | tee -a $LOG
fi

stamp "============================================"
