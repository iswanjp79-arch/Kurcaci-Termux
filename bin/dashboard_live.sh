#!/data/data/com.termux/files/usr/bin/bash
# MICO-JDEQ LIVE DASHBOARD — Real-time, no manual input
while true; do
  clear
  echo "╔════════════════════════════════════════╗"
  echo "║   🛡️ MICO-JDEQ LIVE DASHBOARD        ║"
  echo "║   $(date '+%d %b %Y, %H:%M:%S')        ║"
  echo "╠════════════════════════════════════════╣"
  
  # LLM — cek langsung
  if curl -s --max-time 3 http://localhost:8082/v1/models | grep -q "models"; then
    echo "║ 🧠 LLM MICO       : ✅                  ║"
  else
    echo "║ 🧠 LLM MICO       : ❌ OFFLINE          ║"
  fi
  
  # Node Bridge — cek langsung
  if curl -s --max-time 3 http://localhost:9090/ | grep -q "active\|status"; then
    echo "║ 🌉 Node Bridge    : ✅                  ║"
  else
    echo "║ 🌉 Node Bridge    : ❌ OFFLINE          ║"
  fi
  
  # Ngrok — cek langsung
  if curl -s --max-time 3 http://127.0.0.1:4040/api/tunnels | grep -q "public_url"; then
    echo "║ 🌐 Ngrok          : ✅                  ║"
  else
    echo "║ 🌐 Ngrok          : ❌ OFFLINE          ║"
  fi
  
  # Infinix — cek langsung
  if ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1; then
    echo "║ 📱 Infinix        : ✅                  ║"
  else
    echo "║ 📱 Infinix        : ❌ OFFLINE          ║"
  fi
  
  # RAM — cek langsung
  RAM=$(free -m | awk '/Mem/{print $7}')
  echo "║ 💾 RAM Bebas      : ${RAM} MB             ║"
  
  echo "╚════════════════════════════════════════╝"
  echo "  Live Refresh: 5 detik | $(date '+%H:%M:%S')"
  sleep 5
done
