#!/data/data/com.termux/files/usr/bin/bash
# NAWANG WULAN — 1 KB Cloud → MICO Meledak
CLOUD_URL="https://gist.githubusercontent.com/rinawatimadina-bot/d6bb9d13888b81a680b0eed0420e4373/raw/5be9ed85eccef742d6f515153b8e51b48ab22707/Nawang_Wulan.txt"
LOCAL_SIGNAL="$HOME/JDEQ/.signal_nawang"
LOG="$HOME/JDEQ/log/nawang_wulan.log"
mkdir -p "$(dirname "$LOG")"

echo "$(date): 🌾 Mencari butir padi..." | tee -a "$LOG"
SIGNAL=$(curl -s --max-time 10 "$CLOUD_URL" 2>/dev/null | head -1)
if [ -z "$SIGNAL" ] && [ -f "$LOCAL_SIGNAL" ]; then
    SIGNAL=$(cat "$LOCAL_SIGNAL" | head -1)
    rm -f "$LOCAL_SIGNAL"
    echo "   (sinyal lokal)" | tee -a "$LOG"
fi

if [ "$SIGNAL" = "IGNITE" ]; then
    echo "$(date): 🔥 Sebutir padi diterima! MENANAK NASI..." | tee -a "$LOG"
    termux-wake-lock acquire 2>/dev/null || true
    sleep 1
    
    if ! pgrep -f supervisor_daemon.py > /dev/null; then
        nohup python3 ~/JDEQ/MICO_LIFECYCLE/supervisor_daemon.py > /dev/null 2>&1 &
        echo "   ✅ Supervisor" | tee -a "$LOG"
    else
        echo "   ⏩ Supervisor hidup" | tee -a "$LOG"
    fi
    
    if ! pgrep -f llama-server > /dev/null; then
        nohup llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
            --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 > /dev/null 2>&1 &
        echo "   ✅ LLM" | tee -a "$LOG"
    else
        echo "   ⏩ LLM hidup" | tee -a "$LOG"
    fi
    
    if ! pgrep -f dashboard_server.py > /dev/null; then
        nohup python3 ~/JDEQ/bin/dashboard_server.py > /dev/null 2>&1 &
        echo "   ✅ Dashboard (port 8083)" | tee -a "$LOG"
    fi
    
    python3 -c "
import sys, os
sys.path.insert(0, os.path.expanduser('~/JDEQ/MICO_COGNITIVE'))
from event_engine import process_event
process_event({'action': 'set_goal', 'payload': {'goal': 'MICO dihidupkan oleh Nawang Wulan'}})
process_event({'action': 'reflect', 'payload': {}})
" 2>/dev/null
    echo "   ✅ MICO Cognitive Core" | tee -a "$LOG"
    
    echo "   🍚 NASI MATANG. MICO SIAP." | tee -a "$LOG"
    echo "   Dashboard: http://localhost:8083" | tee -a "$LOG"

elif [ "$SIGNAL" = "STOP" ]; then
    echo "$(date): 🧯 Memadamkan MICO..." | tee -a "$LOG"
    pkill -f supervisor_daemon.py 2>/dev/null || true
    pkill -f llama-server 2>/dev/null || true
    pkill -f dashboard_server.py 2>/dev/null || true
    termux-wake-lock release 2>/dev/null || true
    echo "   ✅ MICO padam." | tee -a "$LOG"

else
    echo "$(date): ⏳ Menunggu butir padi... (sinyal: '$SIGNAL')" | tee -a "$LOG"
fi
