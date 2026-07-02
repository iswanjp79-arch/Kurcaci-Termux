#!/data/data/com.termux/files/usr/bin/bash
echo "╔══════════════════════════════════════╗"
echo "║   MICO-JDEQ START — SATU PENCET    ║"
echo "║   Arsitektur 19 Lantai             ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. LLM
echo "🧠 Menyalakan LLM MICO..."
pgrep llama-server > /dev/null || nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
sleep 2
pgrep llama-server > /dev/null && echo "✅ LLM AKTIF" || echo "❌ LLM GAGAL"

# 2. Node Bridge
echo "🌉 Menyalakan Node Bridge..."
pgrep -f pocketpal_node.js > /dev/null || nohup node ~/JDEQ/bridge/pocketpal_node.js > /dev/null 2>&1 &
sleep 1
pgrep -f pocketpal_node.js > /dev/null && echo "✅ Bridge AKTIF" || echo "❌ Bridge GAGAL"

# 3. Ngrok
echo "🌐 Menyalakan Ngrok..."
pgrep ngrok > /dev/null || nohup ngrok http 8082 --log=stdout > ~/ngrok.log 2>&1 &
sleep 3
pgrep ngrok > /dev/null && echo "✅ Ngrok AKTIF" || echo "❌ Ngrok GAGAL"

# 4. MQTT
echo "📡 Menyalakan MQTT..."
pgrep mosquitto > /dev/null || mosquitto -d 2>/dev/null &
pgrep mosquitto > /dev/null && echo "✅ MQTT AKTIF" || echo "❌ MQTT GAGAL"

# 5. Homeostasis
echo "🩺 Menyalakan Homeostasis..."
pgrep -f node000_homeostasis > /dev/null || nohup python3 ~/JDEQ/NODES/node000_homeostasis.py > /dev/null 2>&1 &
pgrep -f node000_homeostasis > /dev/null && echo "✅ Homeostasis AKTIF" || echo "❌ Homeostasis GAGAL"

# 6. Infinix
echo "📱 Mengecek Infinix..."
ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1 && echo "✅ Infinix AKTIF" || echo "⚠️ Infinix OFFLINE"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✅ SEMUA MODUL SIAP               ║"
echo "║   RAM: $(free -m | awk '/Mem/{print $7}') MB                     ║"
echo "║   Gedung 19 Lantai Beroperasi       ║"
echo "╚══════════════════════════════════════╝"
