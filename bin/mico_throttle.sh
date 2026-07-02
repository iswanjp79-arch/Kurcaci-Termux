#!/data/data/com.termux/files/usr/bin/bash
echo "$(date) - Throttle dijalankan" >> ~/JDEQ/logs/throttle.log
# MICO Auto-Throttle – sesuaikan beban berdasarkan health

HEALTH="/data/data/com.termux/files/home/JDEQ/config/health.json"
if [ ! -f "$HEALTH" ]; then exit 0; fi

BATTERY=$(grep -o '"battery":[0-9]*' "$HEALTH" | cut -d: -f2)
TEMP=$(grep -o '"temp":[0-9]*' "$HEALTH" | cut -d: -f2)

# Jika baterai < 20% atau suhu > 60°C → kill MICO sementara
if [ "$BATTERY" -lt 20 ] || [ "$TEMP" -gt 60 ]; then
    pkill -f "llama-server" 2>/dev/null
    echo "$(date) - Throttle: MICO dimatikan (baterai/suhu kritis)" >> ~/JDEQ/logs/throttle.log
    exit 0
fi

# Jika baterai 20–50% atau suhu 50–60°C → kurangi thread jadi 1, ctx 1024
if [ "$BATTERY" -lt 50 ] || [ "$TEMP" -gt 50 ]; then
    pkill -f "llama-server" 2>/dev/null
    nohup llama-server -m /storage/emulated/0/AI_Models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
      --host 0.0.0.0 --port 8082 --ctx-size 1024 -ngl 0 -t 1 \
      > /data/data/com.termux/files/home/JDEQ/logs/mico_server_throttle.log 2>&1 &
    echo "$(date) - Throttle: MICO restart (mode hemat)" >> ~/JDEQ/logs/throttle.log
    exit 0
fi

# Normal: 1 thread, ctx 2048 (sekarang)
# (sudah dijalankan oleh watchdog, tidak perlu restart)
