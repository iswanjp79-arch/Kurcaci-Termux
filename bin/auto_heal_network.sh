#!/data/data/com.termux/files/usr/bin/bash
# ===================================================
# MICO AUTO-HEAL NETWORK — LOKAL + CLOUD PERMANEN
# DeepSeek Executor — 29 Juni 2026
# ===================================================
LOG="$HOME/JDEQ/logs/auto_heal.log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" >> $LOG; }

# 1. Pastikan LLM hidup
if ! pgrep llama-server > /dev/null; then
  stamp "⚠️ LLM mati — menyalakan..."
  nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
  sleep 5
  pgrep llama-server > /dev/null && stamp "✅ LLM hidup" || stamp "❌ LLM gagal"
fi

# 2. Pastikan Ghost Relay Vivo hidup
if ! pgrep -f "ghost_relay.py" > /dev/null; then
  stamp "⚠️ Ghost Relay Vivo mati — menyalakan..."
  nohup python3 ~/JDEQ/bridge/ghost_relay.py > /dev/null 2>&1 &
  sleep 2
  pgrep -f ghost_relay.py > /dev/null && stamp "✅ Ghost Relay Vivo hidup" || stamp "❌ Ghost Relay Vivo gagal"
fi

# 3. Pastikan ngrok hidup (cloud bridge)
if ! pgrep ngrok > /dev/null; then
  stamp "⚠️ Ngrok mati — menyalakan..."
  nohup ngrok http 8082 > /dev/null 2>&1 &
  sleep 3
  pgrep ngrok > /dev/null && stamp "✅ Ngrok hidup" || stamp "❌ Ngrok gagal"
fi

# 4. Cek koneksi ke Infinix
if ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1; then
  # Update endpoint
  echo "http://100.103.39.81:8000/v1/chat/completions" > ~/JDEQ/bridge/ngrok_url.txt
  
  # Cek layanan Infinix
  if ! curl -s --max-time 3 http://100.103.39.81:8000/health > /dev/null 2>&1; then
    stamp "⚠️ Layanan Infinix mati — tidak bisa diperbaiki dari Vivo"
  else
    stamp "✅ Infinix terhubung & responsif"
  fi
else
  stamp "⚠️ Infinix tidak terjangkau — pastikan WiFi & Tailscale hidup"
fi

stamp "Auto-heal selesai"
