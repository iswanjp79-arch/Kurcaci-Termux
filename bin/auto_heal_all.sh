#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/auto_heal_all.log"
FIXED=0
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "===== AUTO-HEAL CONNECT START ====="

# 1. LLM
if ! pgrep llama-server > /dev/null; then
  stamp "🔧 LLM mati — menyalakan..."
  nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
  sleep 8
  pgrep llama-server > /dev/null && { stamp "✅ LLM pulih"; ((FIXED++)); } || stamp "❌ LLM gagal"
else
  stamp "✅ LLM hidup"
fi

# 2. Node Bridge
if ! pgrep -f pocketpal_node.js > /dev/null; then
  stamp "🔧 Bridge mati — menyalakan..."
  nohup node ~/JDEQ/bridge/pocketpal_node.js > /dev/null 2>&1 &
  sleep 2
  pgrep -f pocketpal_node.js > /dev/null && { stamp "✅ Bridge pulih"; ((FIXED++)); } || stamp "❌ Bridge gagal"
else
  stamp "✅ Bridge hidup"
fi

# 3. Ngrok
if ! pgrep ngrok > /dev/null; then
  stamp "🔧 Ngrok mati — menyalakan..."
  nohup ngrok http 8082 --log=stdout > ~/ngrok.log 2>&1 &
  sleep 4
  pgrep ngrok > /dev/null && { stamp "✅ Ngrok pulih"; ((FIXED++)); } || stamp "❌ Ngrok gagal"
else
  stamp "✅ Ngrok hidup"
fi

# 4. MQTT
if ! pgrep mosquitto > /dev/null; then
  stamp "🔧 MQTT mati — menyalakan..."
  mosquitto -d 2>/dev/null &
  pgrep mosquitto > /dev/null && { stamp "✅ MQTT pulih"; ((FIXED++)); } || stamp "❌ MQTT gagal"
else
  stamp "✅ MQTT hidup"
fi

# 5. Infinix
if ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
  stamp "✅ Infinix terjangkau"
  # Pastikan server Infinix hidup
  if ! curl -s --max-time 3 -X POST http://100.103.39.81:9000 -d '{"cmd":"echo ok"}' | grep -q "ok"; then
    stamp "🔧 Server Infinix mati — mencoba via SSH..."
    ssh -o ConnectTimeout=5 -p 8022 100.103.39.81 "cd ~/JDEQ_CLONE/server && nohup python3 mico_server.py > /dev/null 2>&1 &" 2>/dev/null
    sleep 3
    curl -s --max-time 3 -X POST http://100.103.39.81:9000 -d '{"cmd":"echo ok"}' | grep -q "ok" && { stamp "✅ Infinix pulih"; ((FIXED++)); } || stamp "⚠️ Infinix perlu manual"
  else
    stamp "✅ Server Infinix hidup"
  fi
else
  stamp "⚠️ Infinix tidak terjangkau"
fi

# 6. Uvicorn API
if ! curl -s --max-time 3 http://localhost:9000/health | grep -q "MICO"; then
  stamp "🔧 Uvicorn mati — menyalakan..."
  pkill -f mico_api 2>/dev/null
  nohup python3 ~/JDEQ/server/mico_api.py > /dev/null 2>&1 &
  sleep 2
  curl -s --max-time 3 http://localhost:9000/health | grep -q "MICO" && { stamp "✅ Uvicorn pulih"; ((FIXED++)); } || stamp "❌ Uvicorn gagal"
else
  stamp "✅ Uvicorn hidup"
fi

stamp "===== AUTO-HEAL SELESAI — $FIXED layanan diperbaiki ====="

# Notifikasi jika ada yang diperbaiki
if [ $FIXED -gt 0 ]; then
  bash ~/JDEQ/bin/notify_telegram.sh "🔧 AUTO-HEAL: $FIXED layanan diperbaiki" 2>/dev/null
fi

echo ""
echo "╔══════════════════════════════════╗"
echo "║   ✅ AUTO-HEAL COMPLETE         ║"
echo "║   Diperbaiki: $FIXED layanan          ║"
echo "║   Gedung 19 Lantai SIAP         ║"
echo "╚══════════════════════════════════╝"
