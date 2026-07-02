#!/data/data/com.termux/files/usr/bin/bash
# MICO Dashboard - Termux Jendela 3
clear
echo "╔══════════════════════════════════════════════════╗"
echo "║   🛡️ MICO-JDEQ STATUS DASHBOARD                 ║"
echo "║   $(date '+%d %B %Y, %H:%M:%S')                  ║"
echo "╠══════════════════════════════════════════════════╣"

# Cek LLM
if curl -s --max-time 3 http://localhost:8082/v1/models | grep -q "models"; then
  echo "║ 🧠 LLM MICO       : ✅ ONLINE                  ║"
else
  echo "║ 🧠 LLM MICO       : ❌ OFFLINE                 ║"
fi

# Cek Node Bridge
if curl -s --max-time 3 http://localhost:9090/ | grep -q "active"; then
  echo "║ 🌉 Node Bridge    : ✅ ONLINE                  ║"
else
  echo "║ 🌉 Node Bridge    : ❌ OFFLINE                 ║"
fi

# Cek Ngrok
if curl -s --max-time 3 http://127.0.0.1:4040/api/tunnels | grep -q "public_url"; then
  echo "║ 🌐 Ngrok          : ✅ ONLINE                  ║"
else
  echo "║ 🌐 Ngrok          : ❌ OFFLINE                 ║"
fi

# Cek Infinix
if ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
  echo "║ 📱 Infinix        : ✅ TERHUBUNG               ║"
else
  echo "║ 📱 Infinix        : ❌ TIDAK TERHUBUNG         ║"
fi

# Cek RAM
RAM=$(free -m | awk '/Mem/{print $7}')
echo "║ 💾 RAM Bebas      : ${RAM} MB                  ║"

# Cek SSOT
if [ -f ~/JDEQ/SSOT/MICO-EQ-001-FINAL.md ]; then
  echo "║ 🔒 SSOT           : ✅ TERKUNCI                ║"
else
  echo "║ 🔒 SSOT           : ❌ HILANG                  ║"
fi

echo "╚══════════════════════════════════════════════════╝"
echo "  Refresh: 5 detik | Tekan Ctrl+C untuk keluar"
