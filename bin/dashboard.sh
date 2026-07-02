#!/data/data/com.termux/files/usr/bin/bash
# MICO-JDEQ Dashboard Permanen + Auto-Heal
# Diperbarui: 29 Juni 2026 — LOCK PERMANEN

clear
echo "========================================"
echo " MICO-JDEQ DASHBOARD — $(date '+%H:%M:%S')"
echo "========================================"
echo ""

# --- VIVO Y28 ---
echo "🖥️  VIVO Y28 (Otak Utama)"
RAM_FREE=$(free -m | awk '/Mem/{print $7}')
echo "   RAM: ${RAM_FREE}MB free"

# Cek API (port 8082)
curl -s --max-time 2 http://localhost:8082/v1/models > /dev/null 2>&1 && API="✅" || API="❌"
echo "   API: $API"

# Cek LLM (llama-server)
pgrep llama-server > /dev/null 2>&1 && LLM="✅" || LLM="❌"
echo "   LLM: $LLM"

# Jika LLM mati, auto-start
if [ "$LLM" = "❌" ] && [ -f ~/JDEQ/models/mico.gguf ] && [ "$RAM_FREE" -gt 1500 ]; then
  echo "   ⚡ Auto-heal: Menyalakan LLM..."
  nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
  sleep 5
  pgrep llama-server > /dev/null && echo "   ✅ LLM berhasil dinyalakan" || echo "   ❌ Auto-heal gagal"
fi

# Ghost Relay
pgrep -f ghost_relay.py > /dev/null && GHOST="✅" || GHOST="❌"
echo "   Ghost: $GHOST"

echo ""

# --- INFINIX ---
echo "📱 INFINIX 32-bit (Relay)"
ping -c 1 -W 2 100.103.39.81 > /dev/null 2>&1 && NET="✅ Terhubung" || NET="❌ Putus"
echo "   Jaringan: $NET"
curl -s --max-time 3 http://100.103.39.81:8000/health > /dev/null 2>&1 && LAYANAN="✅" || LAYANAN="❌"
echo "   Layanan: $LAYANAN"

echo ""

# --- COLAB ---
echo "☁️  COLAB"
curl -s --max-time 2 http://localhost:8082/v1/models > /dev/null 2>&1 && COLAB="✅ ONLINE" || COLAB="⏳ TIDAK TERHUBUNG"
echo "   Status: $COLAB"

echo ""
echo "📂 Baseline: $(ls ~/JDEQ/backup/ 2>/dev/null | tail -1)"
echo "📋 Misi Aktif: $(python3 ~/JDEQ/DAL/planner/mission_planner.py --list 2>/dev/null || echo 'Planner siap')"
echo "🌐 Ngrok: $(curl -s http://127.0.0.1:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*' | head -1 | cut -d'"' -f4 || echo 'Tidak aktif')"
echo "========================================"
