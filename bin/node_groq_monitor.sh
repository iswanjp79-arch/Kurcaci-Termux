#!/data/data/com.termux/files/usr/bin/bash
# ========================================
# MICO NODE & GROQ MONITOR - DASHBOARD
# ========================================
clear
echo "╔══════════════════════════════════════╗"
echo "║    🔥 MICO NODE & GROQ MONITOR       ║"
echo "╠══════════════════════════════════════╣"
echo "║       $(date '+%d %b %Y %H:%M:%S')        ║"
echo "╚══════════════════════════════════════╝"
echo ""

# --- STATUS NODE.JS BRIDGE ---
echo "┌─── NODE.JS BRIDGE ──────────────────┐"
if pgrep -f "pocketpal_node.js" > /dev/null; then
    echo "│ Status    : 🟢 ONLINE               │"
    echo "│ Port      : 9090                    │"
    echo "│ PID       : $(pgrep -f pocketpal_node.js | head -1)                     │"
    # Cek respons bridge
    if curl -s --max-time 2 http://localhost:9090 > /dev/null 2>&1; then
        echo "│ Responsif : ✅ YA                   │"
    else
        echo "│ Responsif : ❌ TIDAK                │"
    fi
else
    echo "│ Status    : 🔴 OFFLINE              │"
    echo "│ Aksi      : Jalankan bridge         │"
fi
echo "└──────────────────────────────────────┘"
echo ""

# --- STATUS LLM MICO ---
echo "┌─── LLM MICO ─────────────────────────┐"
if pgrep llama-server > /dev/null; then
    echo "│ Status    : 🟢 ONLINE               │"
    echo "│ Port      : 8082                    │"
    RAM_USED=$(ps -o rss= -p $(pgrep llama-server | head -1) 2>/dev/null | awk '{printf "%.0f", $1/1024}')
    echo "│ RAM       : ${RAM_USED}MB                   │"
    # Uji LLM
    LLM_TEST=$(curl -s --max-time 5 -X POST http://localhost:8082/v1/chat/completions \
      -H "Content-Type: application/json" \
      -d '{"messages":[{"role":"user","content":"1+1"}],"max_tokens":5}' 2>/dev/null | grep -c "choices")
    if [ "$LLM_TEST" -gt 0 ]; then
        echo "│ Responsif : ✅ YA                   │"
    else
        echo "│ Responsif : ❌ TIDAK                │"
    fi
else
    echo "│ Status    : 🔴 OFFLINE              │"
fi
echo "└──────────────────────────────────────┘"
echo ""

# --- STATUS GROQ ---
echo "┌─── GROQ CLOUD ───────────────────────┐"
GROQ_TEST=$(curl -s --max-time 5 -X POST "https://api.groq.com/openai/v1/chat/completions" \
  -H "Authorization: Bearer 3FlqbZT5rsxQ01QyLZRacR2yAA0_2dDELUTxoczSYU2BVokBP" \
  -H "Content-Type: application/json" \
  -d '{"model":"llama3-8b-8192","messages":[{"role":"user","content":"test"}],"max_tokens":1}' 2>/dev/null | grep -c "choices")
if [ "$GROQ_TEST" -gt 0 ]; then
    echo "│ Status    : 🟢 ONLINE               │"
    echo "│ Model     : llama3-8b-8192          │"
else
    echo "│ Status    : 🔴 OFFLINE / ERROR      │"
fi
echo "└──────────────────────────────────────┘"
echo ""

# --- STATUS INFINIX ---
echo "┌─── INFINIX ──────────────────────────┐"
if ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
    echo "│ Status    : 🟢 ONLINE               │"
    echo "│ IP        : 100.103.39.81           │"
    # Cek layanan
    if curl -s --max-time 2 http://100.103.39.81:8000/health 2>/dev/null | grep -q "ok"; then
        echo "│ Layanan   : ✅ Aktif                │"
    else
        echo "│ Layanan   : ❌ Tidak responsif      │"
    fi
else
    echo "│ Status    : 🔴 OFFLINE              │"
fi
echo "└──────────────────────────────────────┘"
echo ""

# --- METRIK SISTEM ---
echo "┌─── METRIK SISTEM ────────────────────┐"
echo "│ RAM Bebas : $(free -m | awk '/Mem/{printf "%.0f MB", $7}')                   │"
echo "│ Suhu CPU  : $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.1f°C", $1/1000}' || echo 'N/A')                   │"
echo "│ Baterai   : $(termux-battery-status 2>/dev/null | grep percentage | awk -F: '{print $2}' | tr -d ' ,' || echo 'N/A')                   │"
echo "│ Penyimpanan: $(df -h ~ | awk 'NR==2 {print $5 " terpakai dari " $2}')                    │"
echo "└──────────────────────────────────────┘"
echo ""

# --- UPDATE OTOMATIS ---
echo "┌─── INFORMASI ────────────────────────┐"
echo "│ Auto-refresh setiap 5 detik          │"
echo "│ Tekan Ctrl+C untuk keluar            │"
echo "└──────────────────────────────────────┘"

# Loop auto-refresh
sleep 5
exec bash ~/JDEQ/bin/node_groq_monitor.sh
