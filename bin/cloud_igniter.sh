#!/data/data/com.termux/files/usr/bin/bash
# URL sinyal cloud — ganti dengan URL raw Gist Anda
SIGNAL_URL="https://gist.githubusercontent.com/raw/sinyal_mico.txt"

SINYAL=$(curl -s "$SIGNAL_URL" 2>/dev/null | head -1)

if [ "$SINYAL" = "IGNITE" ]; then
    echo "$(date): 🔥 Percikan diterima! Menyalakan MICO..."
    termux-wake-lock release 2>/dev/null
    
    if ! pgrep -f supervisor_daemon.py > /dev/null; then
        nohup python3 ~/JDEQ/MICO_LIFECYCLE/supervisor_daemon.py > /dev/null 2>&1 &
        echo "   ✅ Supervisor menyala"
    fi
    
    if ! pgrep -f llama-server > /dev/null; then
        llama-server -m ~/models/core/Qwen2.5-3B-Instruct-Q4_K_M.gguf \
            --host 127.0.0.1 --port 8082 -c 256 -t 1 --no-warmup -ngl 0 > /dev/null 2>&1 &
        echo "   ✅ LLM menyala"
    fi
    
    termux-wake-lock acquire 2>/dev/null
    echo "   🔥 MICO berjalan."
elif [ "$SINYAL" = "STOP" ]; then
    echo "$(date): 🧯 Sinyal STOP. Memadamkan MICO..."
    pkill -f supervisor_daemon.py
    pkill -f llama-server
    termux-wake-lock release 2>/dev/null
    echo "   ✅ MICO padam."
else
    echo "$(date): ⏳ Menunggu percikan..."
fi
